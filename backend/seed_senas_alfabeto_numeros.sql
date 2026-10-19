-- Seed: alfabeto A-Z y números 0-9 (sena + posicion_referencia). Idempotente.
-- Valores de posicion_referencia son provisionales, se ajustan al depurar.

insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-a', 'Letra A', 'Alfabeto', 'Cierra el puño con el pulgar al costado, apoyado junto al índice. Los cuatro dedos quedan doblados hacia la palma.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-a', 26.0, 0.45, array[0, 5, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-b', 'Letra B', 'Alfabeto', 'Levanta los cuatro dedos juntos y rectos hacia arriba. El pulgar se cruza sobre la palma, tocando la base de los dedos.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-b', 40.0, 0.62, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-c', 'Letra C', 'Alfabeto', 'Curva todos los dedos y el pulgar formando la forma de la letra C. La mano debe parecer que sostiene un vaso imaginario.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-c', 18.0, 0.38, array[0, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-d', 'Letra D', 'Alfabeto', 'Extiende el índice hacia arriba. Los demás dedos se curvan y tocan la punta del pulgar formando un círculo.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-d', 18.0, 0.59, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-e', 'Letra E', 'Alfabeto', 'Dobla los cuatro dedos sobre la palma con las puntas tocando el pulgar, que queda cruzado por debajo.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-e', 26.3, 0.51, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-f', 'Letra F', 'Alfabeto', 'Une las puntas del pulgar y el índice formando un círculo. Los otros tres dedos quedan extendidos hacia arriba.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-f', 19.4, 0.87, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-g', 'Letra G', 'Alfabeto', 'Señala hacia el lado con el índice extendido y el pulgar paralelo encima. Los demás dedos quedan cerrados.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-g', 56.6, 0.75, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-h', 'Letra H', 'Alfabeto', 'Extiende el índice y el medio juntos señalando hacia el lado. El pulgar y los otros dedos quedan cerrados.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-h', 24.9, 0.56, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-i', 'Letra I', 'Alfabeto', 'Cierra el puño y levanta solo el meñique. El pulgar descansa sobre los dedos doblados.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-i', 38.3, 0.7, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-j', 'Letra J', 'Alfabeto', 'Levanta el meñique como en la I y dibuja en el aire una letra J con la mano.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-j', 51.7, 0.53, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-k', 'Letra K', 'Alfabeto', 'Extiende índice y medio en V hacia arriba y apoya la punta del pulgar entre ellos, sobre el nudillo del medio.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-k', 16.5, 0.43, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-l', 'Letra L', 'Alfabeto', 'Extiende el índice hacia arriba y el pulgar hacia el lado, formando una L. Los demás dedos quedan cerrados.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-l', 14.8, 0.43, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-m', 'Letra M', 'Alfabeto', 'Cierra el puño y coloca el pulgar debajo de tres dedos (índice, medio y anular).')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-m', 56.2, 0.72, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-n', 'Letra N', 'Alfabeto', 'Cierra el puño y coloca el pulgar debajo de dos dedos (índice y medio).')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-n', 55.5, 0.74, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-o', 'Letra O', 'Alfabeto', 'Une las puntas de todos los dedos con la punta del pulgar formando una O.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-o', 67.1, 0.49, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-p', 'Letra P', 'Alfabeto', 'Haz la seña de la K pero con la mano apuntando hacia abajo.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-p', 63.0, 0.58, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-q', 'Letra Q', 'Alfabeto', 'Haz la seña de la G pero con la mano apuntando hacia abajo.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-q', 57.9, 0.65, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-r', 'Letra R', 'Alfabeto', 'Levanta índice y medio cruzando el medio sobre el índice. Los demás dedos quedan cerrados.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-r', 57.6, 0.52, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-s', 'Letra S', 'Alfabeto', 'Cierra el puño con el pulgar cruzado por delante de los dedos doblados.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-s', 19.5, 0.58, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-t', 'Letra T', 'Alfabeto', 'Cierra el puño y asoma el pulgar entre el índice y el medio.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-t', 65.9, 0.58, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-u', 'Letra U', 'Alfabeto', 'Levanta índice y medio juntos y rectos. Los demás dedos y el pulgar quedan cerrados.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-u', 32.5, 0.57, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-v', 'Letra V', 'Alfabeto', 'Levanta índice y medio separados formando una V. Los demás dedos y el pulgar quedan cerrados.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-v', 27.3, 0.42, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-w', 'Letra W', 'Alfabeto', 'Levanta índice, medio y anular separados. El pulgar sujeta el meñique contra la palma.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-w', 22.2, 0.79, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-x', 'Letra X', 'Alfabeto', 'Cierra el puño y deja el índice doblado en forma de gancho.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-x', 50.3, 0.46, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-y', 'Letra Y', 'Alfabeto', 'Extiende el pulgar y el meñique hacia los lados. Los otros tres dedos quedan cerrados.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-y', 60.3, 0.78, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('alfa-z', 'Letra Z', 'Alfabeto', 'Con el índice extendido, dibuja en el aire una letra Z.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('alfa-z', 69.1, 0.63, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('num-0', 'Número 0', 'Números', 'Une las puntas de todos los dedos con el pulgar formando un círculo, como una O.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('num-0', 18.9, 0.39, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('num-1', 'Número 1', 'Números', 'Levanta solo el índice. Los demás dedos y el pulgar quedan cerrados.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('num-1', 52.0, 0.58, array[0, 5, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('num-2', 'Número 2', 'Números', 'Levanta índice y medio separados formando una V. Los demás dedos quedan cerrados.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('num-2', 48.0, 0.7, array[0, 5, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('num-3', 'Número 3', 'Números', 'Extiende el pulgar, el índice y el medio. El anular y el meñique quedan doblados.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('num-3', 60.0, 0.8, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('num-4', 'Número 4', 'Números', 'Levanta los cuatro dedos separados con el pulgar doblado sobre la palma.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('num-4', 14.0, 0.37, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('num-5', 'Número 5', 'Números', 'Abre la mano con los cinco dedos extendidos y separados.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('num-5', 10.5, 0.71, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('num-6', 'Número 6', 'Números', 'Toca la punta del pulgar con la del meñique. Los otros tres dedos quedan extendidos.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('num-6', 15.2, 0.62, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('num-7', 'Número 7', 'Números', 'Toca la punta del pulgar con la del anular. Los otros tres dedos quedan extendidos.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('num-7', 57.5, 0.57, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('num-8', 'Número 8', 'Números', 'Toca la punta del pulgar con la del medio. Los otros tres dedos quedan extendidos.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('num-8', 48.6, 0.76, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
insert into public.sena (id, nombre, categoria, descripcion) values ('num-9', 'Número 9', 'Números', 'Toca la punta del pulgar con la del índice. Los otros tres dedos quedan extendidos.')
  on conflict (id) do update set nombre=excluded.nombre, categoria=excluded.categoria, descripcion=excluded.descripcion;
insert into public.posicion_referencia (sena_id, angulo_pulgar, distancia_indice_medio, landmarks_clave) values ('num-9', 15.0, 0.62, array[0, 4, 8, 12, 16, 20])
  on conflict (sena_id) do update set angulo_pulgar=excluded.angulo_pulgar, distancia_indice_medio=excluded.distancia_indice_medio, landmarks_clave=excluded.landmarks_clave;
