import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/core/network/api_client.dart';

void main() {
  test('H-06: en release rechaza una API_URL con http', () {
    expect(
      () =>
          ApiClient.validarBaseUrl('http://api.ejemplo.com/api', release: true),
      throwsStateError,
    );
  });

  test('H-06: en release acepta https', () {
    expect(
      ApiClient.validarBaseUrl('https://api.ejemplo.com/api', release: true),
      'https://api.ejemplo.com/api',
    );
  });

  test('H-06: en debug permite el backend local por http', () {
    expect(
      ApiClient.validarBaseUrl('http://localhost:8000/api', release: false),
      'http://localhost:8000/api',
    );
  });
}
