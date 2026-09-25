class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Error del servidor. Intenta más tarde.']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Sin conexión a internet.']);
}

class InvalidImeiException implements Exception {
  final String message;
  InvalidImeiException([this.message = 'El IMEI ingresado no es válido.']);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException([
    this.message = 'No se encontró información para este IMEI.',
  ]);
}
