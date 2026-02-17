import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioFactory {
  static Dio? dio;

  /// Use this method to get a singleton Dio instance.
static getDio() {
    // definition the time required to the server (connect and reverce)
    Duration timeOut = const Duration(seconds: 30);
    if (dio == null) {
      dio = Dio();
      dio!
        ..options.connectTimeout = timeOut
        ..options.contentType =Headers.formUrlEncodedContentType
        ..options.receiveTimeout = timeOut;
      _addContentType();
      _addInterceptors();
      return dio!;
    } else {
      return dio!;
    }
  }
    static _addContentType() async {
    dio?.options.headers = {
      'Content-Type': 'application/json',
      // 'Authorization':
      //     'Bearer ${SharedPref().getString(SharedPrefKey.userToken)}'
    };
  }

  /// Add interceptors (for logging, auth, etc.)
  static void _addInterceptors() {
    dio!.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: true,
        maxWidth: 90,
      ),
    );

    // Example: Add Auth Interceptor
    // dio.interceptors.add(InterceptorsWrapper(
    //   onRequest: (options, handler) {
    //     options.headers["Authorization"] = "Bearer YOUR_TOKEN";
    //     return handler.next(options);
    //   },
    // ));
  }
}
