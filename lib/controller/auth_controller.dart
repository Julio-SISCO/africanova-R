import 'dart:async';
import 'dart:io';

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
import 'package:africanova/static/endpoints.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> checkSecurityQuestion() async {
  const url = Endpoints.login;
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final status = responseData['status'];
      final safe = responseData['safe'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('safe', safe);

      return {
        'status': status,
        'safe': safe,
      };
    } else if (response.statusCode == 422) {
      final responseData = json.decode(response.body);
      return {
        'status': false,
        'message': responseData['error'],
      };
    } else if (response.statusCode == 500) {
      return {
        'status': false,
        'message': "Erreur serveur",
      };
    } else {
      return {
        'status': false,
        'message': "Erreur ${response.statusCode}",
      };
    }
  } on SocketException catch (_) {
    return {
      'status': false,
      'message': 'Aucune connexion Internet',
    };
  } on HttpException catch (_) {
    return {
      'status': false,
      'message': 'Erreur HTTP.',
    };
  } on FormatException catch (_) {
    return {
      'status': false,
      'message': 'Format de réponse non valide.',
    };
  } on TimeoutException catch (_) {
    return {
      'status': false,
      'message': 'Délai d\'attente de la requête dépassé.',
    };
  } catch (e) {
    return {
      'status': false,
      'message': 'Erreur inconnue: $e',
    };
  }
}

Future<Map<String, dynamic>> setSecurityQuestion({
  required String question,
  required String response,
}) async {
  const url = "${Endpoints.security}/store";
  final body = {
    'question': question,
    'response': response,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
        'Content-Type': 'application/json',
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 201) {
      final safe = responseData['safe'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('safe', safe);
      return {
        'status': responseData['status'],
        'message': responseData['message'],
      };
    } else if (response.statusCode == 422) {
      final responseData = json.decode(response.body);
      return {
        'status': false,
        'message': responseData['error'],
      };
    } else if (response.statusCode == 500) {
      return {
        'status': false,
        'message': "Erreur serveur",
      };
    } else {
      return {
        'status': false,
        'message': "Erreur ${response.statusCode}",
      };
    }
  } on SocketException catch (_) {
    return {
      'status': false,
      'message': 'Aucune connexion Internet',
    };
  } on HttpException catch (_) {
    return {
      'status': false,
      'message': 'Erreur HTTP.',
    };
  } on FormatException catch (_) {
    return {
      'status': false,
      'message': 'Format de réponse non valide.',
    };
  } on TimeoutException catch (_) {
    return {
      'status': false,
      'message': 'Délai d\'attente de la requête dépassé.',
    };
  } catch (e) {
    return {
      'status': false,
      'message': 'Erreur inconnue: $e',
    };
  }
}

Future<Map<String, dynamic>> verifySecurityQuestion({
  required String username,
  required String question,
  required String response,
}) async {
  const url = "${Endpoints.security}/verify";
  final body = {
    'username': username,
    'question': question,
    'response': response,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'safe': responseData['safe'],
      };
    } else if (response.statusCode == 401) {
      final responseData = json.decode(response.body);
      return {
        'status': false,
        'message': responseData['error'],
      };
    } else if (response.statusCode == 404) {
      final responseData = json.decode(response.body);
      return {
        'status': false,
        'message': responseData['error'],
      };
    } else if (response.statusCode == 422) {
      final responseData = json.decode(response.body);
      return {
        'status': false,
        'message': responseData['error'],
      };
    } else if (response.statusCode == 500) {
      return {
        'status': false,
        'message': "Erreur serveur",
      };
    } else {
      return {
        'status': false,
        'message': "Erreur ${response.statusCode}",
      };
    }
  } on SocketException catch (_) {
    return {
      'status': false,
      'message': 'Aucune connexion Internet',
    };
  } on HttpException catch (_) {
    return {
      'status': false,
      'message': 'Erreur HTTP.',
    };
  } on FormatException catch (_) {
    return {
      'status': false,
      'message': 'Format de réponse non valide.',
    };
  } on TimeoutException catch (_) {
    return {
      'status': false,
      'message': 'Délai d\'attente de la requête dépassé.',
    };
  } catch (e) {
    return {
      'status': false,
      'message': 'Erreur inconnue: $e',
    };
  }
}

Future<Map<String, dynamic>> login({
  required String username,
  required String password,
}) async {
  const url = Endpoints.login;
  final body = {
    'username': username,
    'password': password,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final token = responseData['token'] ?? '';
      final userData = responseData['user'] ?? {};

      // Stocker le token avec SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      final safe = responseData['safe'];
      await prefs.setBool('safe', safe);

      // Stocker les données utilisateur avec Hive
      var userBox = Hive.box<User>('userBox');
      final user = User.fromJson(userData);
      await userBox.put('currentUser', user);
      return {
        'status': responseData['status'],
        'message': responseData['message'],
      };
    } else if (response.statusCode == 422) {
      final responseData = json.decode(response.body);
      return {
        'status': false,
        'message': responseData['error'],
      };
    } else if (response.statusCode == 400) {
      final responseData = json.decode(response.body);
      return {
        'status': false,
        'message': responseData['error'],
      };
    } else if (response.statusCode == 403) {
      final responseData = json.decode(response.body);
      return {
        'status': false,
        'message': responseData['error'],
      };
    } else if (response.statusCode == 500) {
      return {
        'status': false,
        'message': "Erreur serveur",
      };
    } else {
      return {
        'status': false,
        'message': "Erreur ${response.statusCode}",
      };
    }
  } on SocketException catch (_) {
    return {
      'status': false,
      'message': 'Aucune connexion Internet',
    };
  } on HttpException catch (_) {
    return {
      'status': false,
      'message': 'Erreur HTTP.',
    };
  } on FormatException catch (_) {
    return {
      'status': false,
      'message': 'Format de réponse non valide.',
    };
  } on TimeoutException catch (_) {
    return {
      'status': false,
      'message': 'Délai d\'attente de la requête dépassé.',
    };
  } catch (e) {
    return {
      'status': false,
      'message': 'Erreur inconnue: $e',
    };
  }
}

Future<Map<String, dynamic>> resetPassword({
  required String username,
  required String password,
}) async {
  const url = Endpoints.resetPassword;
  final body = {
    'username': username,
    'password': password,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final token = responseData['token'] ?? '';
      final userData = responseData['user'] ?? {};

      // Stocker le token avec SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      final safe = responseData['safe'];
      await prefs.setBool('safe', safe);

      // Stocker les données utilisateur avec Hive
      var userBox = Hive.box<User>('userBox');
      final user = User.fromJson(userData);
      await userBox.put('currentUser', user);
      return {
        'status': responseData['status'],
        'message': responseData['message'],
      };
    } else if (response.statusCode == 422) {
      final responseData = json.decode(response.body);
      return {
        'status': false,
        'message': responseData['error'],
      };
    } else if (response.statusCode == 500) {
      return {
        'status': false,
        'message': "Erreur serveur",
      };
    } else {
      return {
        'status': false,
        'message': "Erreur ${response.statusCode}",
      };
    }
  } on SocketException catch (_) {
    return {
      'status': false,
      'message': 'Aucune connexion Internet',
    };
  } on HttpException catch (_) {
    return {
      'status': false,
      'message': 'Erreur HTTP.',
    };
  } on FormatException catch (_) {
    return {
      'status': false,
      'message': 'Format de réponse non valide.',
    };
  } on TimeoutException catch (_) {
    return {
      'status': false,
      'message': 'Délai d\'attente de la requête dépassé.',
    };
  } catch (e) {
    return {
      'status': false,
      'message': 'Erreur inconnue: $e',
    };
  }
}

Future<Map<String, dynamic>> register({
  required String username,
  required String password,
}) async {
  const url = Endpoints.register;
  final body = {
    'username': username,
    'password': password,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final token = responseData['token'] ?? '';
      final userData = responseData['user'] ?? {};

      // Stocker le token avec SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      final safe = responseData['safe'];

      await prefs.setBool('safe', safe);

      // Stocker les données utilisateur avec Hive
      var userBox = Hive.box<User>('userBox');
      final user = User.fromJson(userData);
      await userBox.put('currentUser', user);
      return {
        'status': responseData['status'],
        'message': responseData['message'],
      };
    } else if (response.statusCode == 422) {
      final responseData = json.decode(response.body);
      return {
        'status': false,
        'message': responseData['error'],
      };
    } else if (response.statusCode == 500) {
      return {
        'status': false,
        'message': "Erreur serveur",
      };
    } else {
      return {
        'status': false,
        'message': "Erreur ${response.statusCode}",
      };
    }
  } on SocketException catch (_) {
    return {
      'status': false,
      'message': 'Aucune connexion Internet',
    };
  } on HttpException catch (_) {
    return {
      'status': false,
      'message': 'Erreur HTTP.',
    };
  } on FormatException catch (_) {
    return {
      'status': false,
      'message': 'Format de réponse non valide.',
    };
  } on TimeoutException catch (_) {
    return {
      'status': false,
      'message': 'Délai d\'attente de la requête dépassé.',
    };
  } catch (e) {
    return {
      'status': false,
      'message': 'Erreur inconnue: $e',
    };
  }
}

Future<Map<String, dynamic>> setProfile({
  required String nom,
  required String prenom,
  String? email,
  required String adresse,
  required String contact,
  String? phone,
}) async {
  const url = Endpoints.setProfile;
  final body = {
    'nom': nom,
    'prenom': prenom,
    'email': email,
    'adresse': adresse,
    'contact': contact,
    'phone': phone,
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      final employerData = responseData['profile'] ?? {};

      var userBox = Hive.box<User>('userBox');
      final user = userBox.get('currentUser');
      var box = Hive.box<Employer>('employerBox');
      box.add(Employer.fromJson(employerData));

      if (user != null) {
        user.employer =
            employerData.isNotEmpty ? Employer.fromJson(employerData) : null;
        await userBox.put('currentUser', user);
      }
      return {
        'status': responseData['status'],
        'message': responseData['message'],
      };
    } else if (response.statusCode == 422) {
      final responseData = json.decode(response.body);
      return {
        'status': false,
        'message': responseData['error'],
      };
    } else if (response.statusCode == 500) {
      return {
        'status': false,
        'message': "Erreur serveur",
      };
    } else {
      return {
        'status': false,
        'message': "Erreur ${response.statusCode}",
      };
    }
  } on SocketException catch (_) {
    return {
      'status': false,
      'message': 'Aucune connexion Internet',
    };
  } on HttpException catch (_) {
    return {
      'status': false,
      'message': 'Erreur HTTP.',
    };
  } on FormatException catch (_) {
    return {
      'status': false,
      'message': 'Format de réponse non valide.',
    };
  } on TimeoutException catch (_) {
    return {
      'status': false,
      'message': 'Délai d\'attente de la requête dépassé.',
    };
  } catch (e) {
    return {
      'status': false,
      'message': 'Erreur inconnue: $e',
    };
  }
}

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
