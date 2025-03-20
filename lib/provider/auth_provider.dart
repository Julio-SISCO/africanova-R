import 'dart:async';

import 'package:africanova/controller/auth_controller.dart';
import 'package:africanova/database/article.dart';
import 'package:africanova/database/categorie.dart';
import 'package:africanova/database/client.dart';
import 'package:africanova/database/employer.dart';
import 'package:africanova/database/fournisseur.dart';
import 'package:africanova/database/outil.dart';
import 'package:africanova/database/permission.dart';
import 'package:africanova/database/role.dart';
import 'package:africanova/database/service.dart';
import 'package:africanova/database/type_service.dart';
import 'package:africanova/database/user.dart';
import 'package:africanova/database/vente.dart';
import 'package:africanova/view/auth/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> clearAllHiveBoxes() async {
  try {
    await Hive.box<Employer>('employerBox').clear();
    await Hive.box<User>('userBox').clear();
    await Hive.box<User>('otherUser').clear();
    await Hive.box<Categorie>('categorieBox').clear();
    await Hive.box<Article>('articleBox').clear();
    await Hive.box<Client>('clientBox').clear();
    await Hive.box<Fournisseur>('fournisseurBox').clear();
    await Hive.box<Vente>('VenteHistory').clear();
    await Hive.box<Permission>('permissionBox').clear();
    await Hive.box<Permission>('userPermissionBox').clear();
    await Hive.box<Role>('roleBox').clear();
    await Hive.box<Outil>('outilBox').clear();
    await Hive.box<TypeService>('typeServiceBox').clear();
    await Hive.box<Service>('serviceBox').clear();

    final prefs = await SharedPreferences.getInstance();

    bool? savedTheme = prefs.getBool('isLightTheme');
    await prefs.clear();
    if (savedTheme != null) {
      await prefs.setBool('isLightTheme', savedTheme);
    }
  } catch (e) {
    return;
  }
}

Future<void> clearHiveBoxes() async {
  try {
    await Hive.box<Employer>('employerBox').clear();
    await Hive.box<User>('otherUser').clear();
    await Hive.box<Categorie>('categorieBox').clear();
    await Hive.box<Article>('articleBox').clear();
    await Hive.box<Client>('clientBox').clear();
    await Hive.box<Fournisseur>('fournisseurBox').clear();
    await Hive.box<Vente>('VenteHistory').clear();
    await Hive.box<Permission>('permissionBox').clear();
    await Hive.box<Permission>('userPermissionBox').clear();
    await Hive.box<Role>('roleBox').clear();
    await Hive.box<Outil>('outilBox').clear();
    await Hive.box<TypeService>('typeServiceBox').clear();
    await Hive.box<Service>('serviceBox').clear();
  } catch (e) {
    return;
  }
}

Future<String> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token') ?? '';
}

Future<bool> getSafe() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('safe') ?? false;
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

Future<void> setLastLoginTime() async {
  final prefs = await SharedPreferences.getInstance();
  final currentTime = DateTime.now().millisecondsSinceEpoch;
  await prefs.setInt('lastLoginTime', currentTime);
}

Future<bool> isSessionExpired() async {
  final prefs = await SharedPreferences.getInstance();
  final lastLoginTime = prefs.getInt('lastLoginTime') ?? 0;
  final currentTime = DateTime.now().millisecondsSinceEpoch;

  final expiryDuration = 8 * 60 * 60 * 1000;

  if (currentTime - lastLoginTime > expiryDuration) {
    return true;
  }

  return false;
}

Future<void> _logout() async {
  final result = await logout();
  if (result['status'] == true) {
    await clearAllHiveBoxes();
    Get.offAll(AuthPage());
  }

  Get.snackbar(
    '',
    result["message"],
    titleText: SizedBox.shrink(),
    messageText: Center(
      child: Text(
        result["message"],
        style: TextStyle(
          color: Color(0xFF262D4D),
        ),
      ),
    ),
    maxWidth: 400,
    snackPosition: SnackPosition.BOTTOM,
  );
}

void startSessionCheck() {
  Timer.periodic(Duration(minutes: 1), (timer) async {
    bool expired = await isSessionExpired();
    if (expired) {
      await _logout();
    }
  });
}
