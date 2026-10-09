import 'package:withsave_frontend_test/model/entities/user.dart';
import 'package:withsave_frontend_test/model/services/api_client.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<void> signup({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final String token = await _api.post(
      '/users/create/user/email',
      data: {
        "email": email,
        "password": password,
        "nickname": nickname,
      },
    );
    await _api.saveToken(token);
  }

  Future<void> login({
    required String password,
    required String nickname,
  }) async {
    final String token = await _api.post(
      '/users/nickname/login',
      data: {
        "password": password,
        "nickname": nickname,
      },
    );
    await _api.saveToken(token);
  }

  Future<User> loadProfile() async {
    final data = await _api.get(
      '/users/myInfo',
    );
    return User.fromJson(data);
  }

  Future<void> patchProfile({
    String? password,
    String? nickname,
  }) async {
    await _api.patch(
      '/users/',
      data: {
        if (nickname != null) "nickname": nickname,
        if (password != null) "password": password,
      },
    );
  }

  Future<void> deleteProfile({required int userId}) async {
    await _api.delete('/users/$userId');
    await _api.clearToken();
  }

  Future<void> logout() async => _api.clearToken();

  Future<bool> checkEmail({required String email}) async {
    final result = await _api.get(
      '/users/check/email/exist',
      query: {"email": email},
    );
    return result == true;
  }

  Future<bool> checkNickname({required String nickname}) async {
    final result = await _api.get(
      '/users/check/nickname/exist/nickname',
      query: {"nickname": nickname},
    );
    return result == true;
  }
}
