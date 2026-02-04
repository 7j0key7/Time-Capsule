import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _usersKey = 'users_map'; // login -> hash
  static const _currentUserKey = 'current_user';

  static String _hash(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  static Future<Map<String, String>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    final map = Map<String, dynamic>.from(decoded);
    return map.map((k, v) => MapEntry(k.toString(), v.toString()));
  }

  static Future<void> _saveUsers(Map<String, String> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  static Future<bool> register({
    required String login,
    required String password,
  }) async {
    final l = login.trim();
    if (l.isEmpty || password.isEmpty) return false;

    final users = await _loadUsers();
    if (users.containsKey(l)) return false;

    users[l] = _hash(password);
    await _saveUsers(users);
    return true;
  }

  static Future<bool> login({
    required String login,
    required String password,
  }) async {
    final l = login.trim();
    if (l.isEmpty || password.isEmpty) return false;

    final users = await _loadUsers();
    final savedHash = users[l];
    if (savedHash == null) return false;

    final enteredHash = _hash(password);
    if (enteredHash != savedHash) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, l);
    return true;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  static Future<String?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }
}
