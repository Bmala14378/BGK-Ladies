class UserNotFoundException implements Exception {}

class InvalidPasswordException implements Exception {}
class InvalidCredentialException implements Exception {}

class TooManyRequestsException implements Exception {}

class UnknownAuthException implements Exception {
  final String message;
  UnknownAuthException(this.message);
}

class UserDisabledException implements Exception {}

class NetworkException implements Exception {}

class UserAlreadyInUseException implements Exception {}
