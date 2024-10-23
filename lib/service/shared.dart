class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);
}
class BlockedUserException implements Exception {}
class UserNotFoundException implements Exception {}
class ConflictedUserException implements Exception {}

class PasswordResetException implements Exception {
  final String message;
  PasswordResetException(this.message);
}
class NotAcceptedException implements Exception {
  final String message;
  NotAcceptedException(this.message);
}
