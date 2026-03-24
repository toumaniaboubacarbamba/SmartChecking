class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class AuthException extends AppException {
  AuthException(super.message);
}

class NetworkException extends AppException{
  NetworkException(super.message);
}

class CacheException extends AppException{
  CacheException(super.message);
}


class ServerException extends AppException{
  ServerException(super.message);
}