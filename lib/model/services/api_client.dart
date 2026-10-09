import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await readToken();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await clearToken();
            onUnauthorized?.call;
          }
          handler.next(error);
        },
      ),
    );
  }

  static const String baseUrl = 'https://front-test.alex-choi.com';
  static const String _tokenKey = 'access_token';

  final Dio dio;
  String? _token;

  void Function()? onUnauthorized;

  Future<String?> readToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    return _token = prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async =>
      _send(() => dio.get(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? data}) async =>
      _send(() => dio.post(path, data: data));

  Future<dynamic> patch(String path, {Object? data}) async =>
      _send(() => dio.patch(path, data: data));

  Future<dynamic> delete(String path, {Map<String, dynamic>? query}) async =>
      _send(() => dio.delete(path, queryParameters: query));

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return unwrap(response.data);
    } on DioException catch (e) {
      throw ApiException(_messageOf(e), statusCode: e.response?.statusCode);
    }
  }

  static dynamic unwrap(dynamic body) {
    var value = body;
    final String key = 'result';

    while (value is Map && value.containsKey(key)) {
      value = value[key];
    }
    return value;
  }

  static String _messageOf(DioException e) {
    dynamic body = e.response?.data;
    if (body is Map && body['result'] is Map) body = body['result'];
    if (body is Map) {
      final message = body['message'];
      if (message is List) return message.join('\n');
      if (message is String && message.isNotEmpty) return message;
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return '서버에 연결할 수 없습니다. 네트워크를 확인해주세요.';
      default:
        return '요청을 처리하지 못했습니다. (${e.response?.statusCode ?? '알 수 없는 오류'})';
    }
  }
}
