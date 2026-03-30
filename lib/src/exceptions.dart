// exceptions.dart — PkException hierarchy.

import 'enums.dart';

/// Base exception for PackageKit errors.
class PkException implements Exception {
  final String message;
  const PkException(this.message);

  @override
  String toString() => 'PkException: $message';
}

/// Thrown when the PackageKit daemon is not available.
class PkServiceUnavailableException extends PkException {
  const PkServiceUnavailableException(super.message);

  @override
  String toString() => 'PkServiceUnavailableException: $message';
}

/// Thrown when a transaction fails (non-success exit code).
class PkTransactionException extends PkException {
  final PkExit exit;
  final int runtimeMs;

  const PkTransactionException(
    super.message, {
    required this.exit,
    required this.runtimeMs,
  });

  @override
  String toString() =>
      'PkTransactionException: $message (exit=${exit.name}, ${runtimeMs}ms)';
}
