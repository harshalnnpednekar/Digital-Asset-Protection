import 'package:dio/dio.dart';

final Dio dioClient = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 120),
))
  ..interceptors.add(
    InterceptorsWrapper(
      onError: (DioException e, handler) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.error?.toString().contains('SocketException') == true) {
          // Display user friendly message
          print(
              "Connection error: Ensure ngrok backend is running and URL is correct.");
        }
        return handler.next(e);
      },
    ),
  );
