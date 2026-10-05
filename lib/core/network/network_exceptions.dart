/// Custom exceptions for network and API error handling.
library;

/// Thrown when an API request fails.
class ApiException implements Exception {
  /// Creates an [ApiException] with an error [message] and optional [statusCode].
  const ApiException({required this.message, this.statusCode});

  /// Human-readable error message.
  final String message;

  /// HTTP status code, if available.
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thrown when a network connectivity issue occurs.
class NetworkException implements Exception {
  /// Creates a [NetworkException] with an error [message].
  const NetworkException({required this.message});

  /// Human-readable error message.
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when a WebSocket connection fails or is interrupted.
class WebSocketException implements Exception {
  /// Creates a [WebSocketException] with an error [message].
  const WebSocketException({required this.message});

  /// Human-readable error message.
  final String message;

  @override
  String toString() => 'WebSocketException: $message';
}
