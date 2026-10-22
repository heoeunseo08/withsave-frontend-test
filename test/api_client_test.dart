import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:withsave_frontend_test/model/services/api_client.dart';

DioException _error(int status, String message, {bool withToken = true}) {
  final options = RequestOptions(
    headers: {if (withToken) 'Authorization': 'Bearer x'},
  );
  return DioException(
    requestOptions: options,
    response: Response(
      requestOptions: options,
      statusCode: status,
      data: {'message': message},
    ),
  );
}

void main() {
  test('토큰을 보낸 요청의 500 jwt 오류는 만료로 본다', () {
    expect(ApiClient.isTokenError(_error(500, 'jwt malformed')), isTrue);
    expect(ApiClient.isTokenError(_error(500, 'invalid signature')), isTrue);
  });

  test('토큰이 없거나 다른 오류면 만료로 보지 않는다', () {
    expect(ApiClient.isTokenError(_error(500, 'jwt malformed', withToken: false)), isFalse);
    expect(ApiClient.isTokenError(_error(500, 'Cannot read properties of null')), isFalse);
    expect(ApiClient.isTokenError(_error(400, 'jwt malformed')), isFalse);
  });
}
