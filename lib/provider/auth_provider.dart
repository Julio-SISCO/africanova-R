

import 'package:africanova/database/user.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token') ?? '';
}

Future<bool> isUserLoggedIn() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.containsKey('token');
}

Future<User?> getAuthUser() async {
  var userBox = Hive.box<User>('userBox');
  final user = userBox.get('currentUser');
  return user;
}