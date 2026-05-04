class AuthService {
  static const _adminUsername = 'admin';
  static const _adminPassword = 'admin123';

  static bool authenticate(String username, String password) {
    return username == _adminUsername && password == _adminPassword;
  }
}
