// exceptions.dart — PkException hierarchy.

import 'enums.dart';

/// Base exception for PackageKit errors.
class PkException implements Exception {
  /// Human-readable error message.
  final String message;

  /// Creates a [PkException] with the given [message].
  const PkException(this.message);

  @override
  String toString() => 'PkException: $message';
}

/// Thrown when the PackageKit daemon is not available.
class PkServiceUnavailableException extends PkException {
  /// Creates a [PkServiceUnavailableException] with the given [message].
  const PkServiceUnavailableException(super.message);

  @override
  String toString() => 'PkServiceUnavailableException: $message';
}

/// Thrown when a transaction fails (non-success exit code).
class PkTransactionException extends PkException {
  /// The exit code returned by the transaction.
  final PkExit exit;

  /// Wall-clock runtime of the transaction in milliseconds.
  final int runtimeMs;

  /// Creates a [PkTransactionException] with the given [message], [exit]
  /// code, and [runtimeMs].
  const PkTransactionException(
    super.message, {
    required this.exit,
    required this.runtimeMs,
  });

  @override
  String toString() =>
      'PkTransactionException: $message (exit=${exit.name}, ${runtimeMs}ms)';
}