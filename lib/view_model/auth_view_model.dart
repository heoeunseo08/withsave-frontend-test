import 'package:flutter/cupertino.dart';
import 'package:withsave_frontend_test/model/entities/user.dart';
import 'package:withsave_frontend_test/model/repositories/user_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repo);

  final UserRepository _repo;

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;

  bool get isLogin => _user != null;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool isMine(int userId) => _user?.id == userId;

  Future<void> init() async {
    try {
      _user = await _repo.loadProfile();
    } catch (e) {
      _user = null;
    }
    notifyListeners();
  }

  Future<bool> login({required String nickname, required String password}) =>
      _run(
        () async {
          await _repo.login(password: password, nickname: nickname);
          _user = await _repo.loadProfile();
        },
      );

  Future<bool> signup({
    required String email,
    required String nickname,
    required String password,
  }) async => _run(
    () async {
      await _repo.signup(email: email, password: password, nickname: nickname);
      _user = await _repo.loadProfile();
    },
  );

  Future<bool> deleteProfile() async => _run(() async {
    final id = _user?.id;
    if (id == null) return;
    await _repo.deleteProfile(userId: id);
    _user = null;
  });

  Future<bool> updateProfile({
    required String? nickname,
    required String? password,
  }) async => _run(
    () async {
      await _repo.patchProfile(
        nickname: nickname,
        password: password,
      );
      _user = await _repo.loadProfile();
    },
  );

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    notifyListeners();
  }

  void onSessionExpired() {
    if (_user == null) return;
    _user = null;
    _error = '로그인이 만료되었습니다. 다시 로그인해주세요.';
    notifyListeners();
  }

  Future<bool> isCheckEmail(String email) => _repo.checkEmail(email: email);

  Future<bool> isCheckNickname(String nickname) =>
      _repo.checkNickname(nickname: nickname);

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await task();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
