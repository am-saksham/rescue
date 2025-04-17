import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userProfilePicKey = 'user_profile_pic';
  static const String _isLoggedInKey = 'is_logged_in';

  static Future<void> saveUserData({
    required String email,
    required String name,
    required String profilePic,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userProfilePicKey, profilePic);
    await prefs.setBool(_isLoggedInKey, true);
  }

  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_userEmailKey),
      'name': prefs.getString(_userNameKey),
      'profilePic': prefs.getString(_userProfilePicKey),
    };
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userProfilePicKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }
}