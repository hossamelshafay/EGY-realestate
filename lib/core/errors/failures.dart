import 'package:equatable/equatable.dart';

/// Base class for all domain-layer failures.
///
/// Repositories catch exceptions from datasources and convert them to
/// [Failure] subtypes before returning to Cubits. Cubits map failures to
/// error states with a user-visible [message].
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// A network or transport error (timeout, no connectivity, DNS failure).
final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection. Please check your network.',
  ]);
}

/// An HTTP error returned by the server (4xx / 5xx).
final class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// A Firebase Authentication error.
final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// A Firestore or local storage read/write error.
final class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// An operation that requires authentication was attempted without a session.
final class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure([
    super.message = 'You must be signed in to perform this action.',
  ]);
}
