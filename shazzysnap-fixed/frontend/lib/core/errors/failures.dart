abstract class Failure implements Exception {
  final String message;
  const Failure(this.message);
  @override
  String toString() => message;
}
class NetworkFailure extends Failure { const NetworkFailure([String m = 'Network error']) : super(m); }
class TimeoutFailure extends Failure { const TimeoutFailure([String m = 'Timed out']) : super(m); }
class InvalidUrlFailure extends Failure { const InvalidUrlFailure([String m = 'Invalid URL']) : super(m); }
class UnauthorizedPlatformFailure extends Failure { const UnauthorizedPlatformFailure([String m = 'Platform not authorized']) : super(m); }
class DownloadFailure extends Failure { const DownloadFailure([String m = 'Download failed']) : super(m); }
class StorageFailure extends Failure { const StorageFailure([String m = 'Storage error']) : super(m); }
class PermissionFailure extends Failure { const PermissionFailure([String m = 'Permission denied']) : super(m); }
class ServerFailure extends Failure { final int? statusCode; const ServerFailure([String m = 'Server error', this.statusCode]) : super(m); }
class AuthFailure extends Failure { const AuthFailure([String m = 'Auth failed']) : super(m); }
