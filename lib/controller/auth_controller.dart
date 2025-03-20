import 'dart:async';
import 'dart:io';

import 'package:africanova/database/employer.dart';
import 'package:africanova/database/user.dart';
import 'package:africanova/provider/auth_provider.dart';
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
      setLastLoginTime();
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

Future<Map<String, dynamic>> logout() async {
  const url = Endpoints.logout;

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
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
      setLastLoginTime();
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
