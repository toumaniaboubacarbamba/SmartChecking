import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_checking/entities/account.dart';
import 'package:smart_checking/models/userModel.dart';

class Storageservice {
  static const _userKey = 'cached_user';

  Future<void> saveUser(Usermodel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<Account?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json == null) return null;
    return Usermodel.fromJson(jsonDecode(json));
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);

    Future<String?> getToken() async {
      final user = await getUser();
      return user?.token;
    }
  }
}