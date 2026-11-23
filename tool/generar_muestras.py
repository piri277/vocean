"""Genera assets/data/muestras_senas.json desde las muestras grabadas.

Uso: python3 tool/generar_muestras.py muestras.jsonl

Lee las líneas `MUESTRA {...}` (o el JSON solo) del modo captura, quita
duplicados y calcula lo que ClasificadorKnn necesita:
  - escala: desviación típica de cada rasgo dentro de una misma letra.
  - umbrales: por letra, [distancia, desvío por dedo] para aceptar (verde).
  - control: rasgos sin normalizar de la primera muestra, para que el test de
    Dart compruebe que calcula los mismos rasgos que este script.

Los rasgos deben coincidir con ClasificadorKnn.rasgos.
"""

import json
import math
import sys
from collections import defaultdict

# Letras de las que solo valen las tandas desde este número (0 = la primera):
# las dos primeras C tenían la mano mal puesta y aceptaban casi cualquier pose.
DESDE_TANDA = {'c': 2}

# Umbral por letra = A × percentil 90 de la distancia de cada muestra a su
# vecina más cercana de la misma letra y cámara, acotado a [MIN, MAX].
# Los pisos dejan margen a otra persona: con muestras de una sola mano, alguien
# que dobla los dedos ~12° distinto quedaba en naranja (38 % de fotogramas en
# verde); con estos pisos llega al 75 %, a cambio de que un dedo movido pase el
# 7 % de las veces en vez del 3 %. Grabar muestras de más personas es mejor.
A, DIST_MIN, DIST_MAX, DEDO_MIN, DEDO_MAX = 1.5, 1.5, 1.8, 2.2, 2.4

CADENAS = [[0, 1, 2, 3, 4], [0, 5, 6, 7, 8], [0, 9, 10, 11, 12],
           [0, 13, 14, 15, 16], [0, 17, 18, 19, 20]]
PUNTAS = [4, 8, 12, 16, 20]
APOYOS_PULGAR = [5, 6, 9, 10, 13, 14]


def angulo(a, b, c):
    u = [a[i] - b[i] for i in range(3)]
    v = [c[i] - b[i] for i in range(3)]
    m = math.dist(a, b) * math.dist(c, b)
    if m == 0:
        return 0.0
    return math.acos(max(-1.0, min(1.0, sum(u[i] * v[i] for i in range(3)) / m))) / math.pi


def rasgos(p, aspecto):
    P = [(p[3 * i] * aspecto, p[3 * i + 1], p[3 * i + 2] * aspecto) for i in range(21)]
    palma = max(math.dist(P[0], P[9]), 1e-6)
    d = lambda a, b: math.dist(P[a], P[b]) / palma
    v = [angulo(P[c[j - 1]], P[c[j]], P[c[j + 1]]) for c in CADENAS for j in (1, 2, 3)]
    v += [d(PUNTAS[i], PUNTAS[j]) for i in range(5) for j in range(i + 1, 5)]
    v += [d(t, 0) for t in PUNTAS]
    v += [d(4, a) for a in APOYOS_PULGAR]
    return v


def leer(ruta):
    vistas, filas = set(), []
    for linea in open(ruta, encoding='utf-8'):
        linea = linea.strip()
        i = linea.find('{')
        if i < 0 or linea[i:] in vistas:
            continue
        vistas.add(linea[i:])
        filas.append(json.loads(linea[i:]))
    # Tandas: corridas seguidas de la misma letra y cámara, de a 30.
    # _t: tanda global; _n: número de tanda dentro de su letra.
    tanda, previa, n, n_letra, por_letra = -1, None, 0, 0, defaultdict(int)
    for f in filas:
        f['s'] = f['sena'].removeprefix('alfa-')
        clave = (f['s'], f['frontal'])
        if clave != previa or n >= 30:
            tanda += 1
            n = 0
            n_letra = por_letra[f['s']]
            por_letra[f['s']] += 1
        previa, n = clave, n + 1
        f['_t'], f['_n'] = tanda, n_letra
    return [f for f in filas if f['_n'] >= DESDE_TANDA.get(f['s'], 0)]


def main():
    filas = leer(sys.argv[1])
    X = [rasgos(f['p'], f['aspecto']) for f in filas]
    D = len(X[0])
    grupos = defaultdict(list)
    for x, f in zip(X, filas):
        grupos[f['s']].append(x)
    escala = []
    for k in range(D):
        suma, grados = 0.0, 0
        for xs in grupos.values():
            media = sum(x[k] for x in xs) / len(xs)
            suma += sum((x[k] - media) ** 2 for x in xs)
            grados += len(xs) - 1
        escala.append(max(math.sqrt(suma / max(grados, 1)), 1e-3))
    Z = [[x[k] / escala[k] for k in range(D)] for x in X]

    def dist(a, b):
        return math.sqrt(sum((p - q) ** 2 for p, q in zip(a, b)) / D)

    def peor_dedo(a, b):
        return max(math.sqrt(sum((a[q] - b[q]) ** 2 for q in range(3 * f, 3 * f + 3)) / 3)
                   for f in range(5))

    posicion = {}
    for i, f in enumerate(filas):
        posicion[i] = sum(1 for j in range(i) if filas[j]['_t'] == f['_t'])

    def p90(xs):
        xs = sorted(xs)
        return xs[min(len(xs) - 1, int(0.9 * len(xs)))]

    umbrales = {}
    for letra in sorted(grupos):
        ds, ws = [], []
        for i, f in enumerate(filas):
            if f['s'] != letra:
                continue
            misma = [j for j, g in enumerate(filas)
                     if g['s'] == letra and g['frontal'] == f['frontal']]
            otras = [j for j in misma if filas[j]['_t'] != f['_t']]
            # Sin otra tanda de esa cámara: muestras de la misma tanda pero
            # separadas, para no medir contra la vecina casi idéntica.
            pool = otras or [j for j in misma if filas[j]['_t'] == f['_t']
                             and abs(posicion[j] - posicion[i]) >= 10]
            if not pool:
                continue
            j = min(pool, key=lambda j: dist(Z[i], Z[j]))
            ds.append(dist(Z[i], Z[j]))
            ws.append(peor_dedo(Z[i], Z[j]))
        if ds:
            umbrales[letra] = [
                round(min(DIST_MAX, max(DIST_MIN, A * p90(ds))), 3),
                round(min(DEDO_MAX, max(DEDO_MIN, A * p90(ws))), 3),
            ]

    salida = {
        'escala': [round(e, 6) for e in escala],
        'umbrales': umbrales,
        'control': [round(v, 6) for v in X[0]],
        'muestras': [{'s': f['s'], 'f': f['frontal'], 'a': f['aspecto'], 'p': f['p'][:63]}
                     for f in filas],
    }
    with open('assets/data/muestras_senas.json', 'w', encoding='utf-8') as fh:
        json.dump(salida, fh, separators=(',', ':'), ensure_ascii=False)
    print(len(filas), 'muestras;', ' '.join(f'{k}:{v[0]}/{v[1]}' for k, v in umbrales.items()))


if __name__ == '__main__':
    main()
