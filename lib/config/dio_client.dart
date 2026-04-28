// ============================================================
// ASTRA AI — Global Dio HTTP Client
// ============================================================
// This file creates a single, reusable Dio instance that every
// service/screen in the app should use for backend calls.
// It sets timeouts suitable for video processing and includes
// a global error interceptor so the app never crashes on
// network failures — it returns a friendly error message instead.
// ============================================================

import 'dart:io';
import 'package:dio/dio.dart';
import 'api_config.dart';

// ----------------------------------------------------------
// Global Dio instance — import this wherever you need to
// make HTTP calls to the ASTRA AI backend.
//
// Usage example:
//   import 'package:sentinel_ai/config/dio_client.dart';
//
//   final response = await dio.get('/scan/status');
//   final response = await dio.post('/upload', data: formData);
// ----------------------------------------------------------
final Dio dio = _createDioClient();

/// Creates and configures the Dio HTTP client with:
/// - Base URL pointing to the ngrok tunnel (from api_config.dart)
/// - Connection timeout of 30 seconds
/// - Receive timeout of 120 seconds (videos take time to process)
/// - A global error interceptor for graceful error handling
Dio _createDioClient() {
  final Dio dioInstance = Dio(
    BaseOptions(
      // Base URL from the central config file — all requests
      // will be relative to this (e.g., dio.get('/health') calls
      // https://YOUR-NGROK-URL.ngrok-free.app/health)
      baseUrl: ApiConfig.backendBaseUrl,

      // How long to wait while trying to establish a connection
      // to the server. 30 seconds is generous for a tunnel.
      connectTimeout: const Duration(seconds: 30),

      // How long to wait for the server to send back a response.
      // Set to 120 seconds because video processing (frame
      // extraction, AI analysis) can take over a minute.
      receiveTimeout: const Duration(seconds: 120),

      // Default headers sent with every request
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // ----------------------------------------------------------
  // Global Error Interceptor
  // Catches all network and server errors so the app never
  // crashes with an unhandled exception. Instead, it wraps
  // errors into a clean DioException with a user-friendly message.
  // ----------------------------------------------------------
  dioInstance.interceptors.add(
    InterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) {
        String friendlyMessage;

        // Check what type of error occurred and assign a
        // human-readable message the UI can display directly.
        if (error.error is SocketException) {
          // SocketException = device has no internet or server is down
          friendlyMessage =
              'Cannot reach the server. Check your internet connection '
              'and make sure the backend is running.';
        } else if (error.type == DioExceptionType.connectionTimeout) {
          // Took too long to even establish a connection
          friendlyMessage =
              'Connection timed out. The server may be down or the '
              'ngrok tunnel may have expired. Restart ngrok and update '
              'the URL in api_config.dart.';
        } else if (error.type == DioExceptionType.receiveTimeout) {
          // Connected OK but the server is taking too long to respond
          friendlyMessage =
              'The server is taking too long to respond. The video may '
              'be too large, or the AI pipeline is overloaded. Try a '
              'shorter clip.';
        } else if (error.type == DioExceptionType.badResponse) {
          // Server responded with an error status code (4xx/5xx)
          final statusCode = error.response?.statusCode ?? 0;
          if (statusCode == 404) {
            friendlyMessage = 'Endpoint not found. Check the API route.';
          } else if (statusCode == 500) {
            friendlyMessage =
                'Internal server error. Check the Python backend logs.';
          } else {
            friendlyMessage = 'Server error (HTTP $statusCode). '
                'Check the backend logs for details.';
          }
        } else {
          // Catch-all for any other Dio errors
          friendlyMessage =
              'Something went wrong. Please try again. '
              'Error: ${error.message ?? "Unknown error"}';
        }

        // Reject with a new DioException that carries the
        // friendly message — callers can access it via
        // catch (e) { print(e.message); }
        handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: error.type,
            error: error.error,
            message: friendlyMessage,
          ),
        );
      },
    ),
  );

  return dioInstance;
}
