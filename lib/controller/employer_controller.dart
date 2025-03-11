import 'dart:async';
import 'dart:io';

import 'package:africanova/controller/auth_controller.dart';
import 'package:africanova/database/employer.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> sendEmployer({
  String? adresse,
  String? email,
  String? phone,
  required String nom,
  required String prenom,
  required String contact,
}) async {
  try {
    final body = {
      'adresse': adresse,
      'email': email,
      'phone': phone,
      'nom': nom,
      'prenom': prenom,
      'contact': contact,
    };

    final response = await http.post(
      Uri.parse(Endpoints.employer),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    final responseData = json.decode(response.body);
    // Vérification de la réponse du serveur
    if (response.statusCode == 201) {
      Employer employer = Employer.fromJson(responseData['employer']);

      var box = Hive.box<Employer>('employerBox');
      List<Employer> existingEmployers = box.values.toList();
      // Inverser la liste des employers
      existingEmployers = existingEmployers.reversed.toList();
      // Ajouter le nouvel employer à la liste inversée
      existingEmployers.add(employer);
      // Inverser la liste des employers à nouveau
      existingEmployers = existingEmployers.reversed.toList();
      await box.clear();
      await box.addAll(existingEmployers);
    }
    return {
      'status': responseData['status'],
      'message': responseData['message'],
    };
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

Future<Map<String, dynamic>> updateEmployer({
  required String nom,
  required String prenom,
  String? email,
  required String contact,
  String? phone,
  String? adresse,
  required int id,
}) async {
  final url = Uri.parse('${Endpoints.employer}/$id');

  final body = {
    'adresse': adresse,
    'email': email,
    'phone': phone,
    'nom': nom,
    'prenom': prenom,
    'contact': contact,
  };

  try {
    final response = await http.put(
      url,
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    final responseData = json.decode(response.body);
    // Vérification de la réponse du serveur
    if (response.statusCode == 200) {
      // Si la réponse est un succès, ajouter le nouvel employer dans Hive
      Employer employer = Employer.fromJson(responseData['employer']);

      var box = Hive.box<Employer>('employerBox');
      int? employerIndex;

      // Trouver l'index de l'employer à mettre à jour basé sur l'ID
      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          employerIndex = i;
          break;
        }
      }
      if (employerIndex != null) {
        await box.putAt(employerIndex, employer);
      }
    }
    return {
      'status': responseData['status'],
      'message': responseData['message'],
    };
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

Future<Map<String, dynamic>> getEmployers() async {
  final url = Uri.parse(Endpoints.employer);
  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
        'Content-Type': 'application/json',
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseData['employers'] != null &&
          responseData['employers'].isNotEmpty) {
        final List<dynamic> employersJson = responseData['employers'];

        List<Employer> employers = employersJson
            .map((json) => Employer.fromJson(json as Map<String, dynamic>))
            .toList();

        var box = await Hive.openBox<Employer>('employerBox');
        await box.clear();

        for (var employer in employers.reversed) {
          await box.add(employer);
        }
      }
    }

    return {
      'status': responseData['status'],
      'message': responseData['message'],
    };
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

Future<Map<String, dynamic>> supprimerEmployer(int id) async {
  final String url = '${Endpoints.employer}/$id';

  try {
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      var box = await Hive.openBox<Employer>('employerBox');
      int? employerIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          employerIndex = i;
          break;
        }
      }

      if (employerIndex != null) {
        await box.deleteAt(employerIndex);
      }
    }
    return {
      'status': responseData['status'],
      'message': responseData['message'],
    };
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

Future<bool?> showConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmation'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce personnel ?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Confirmer'),
          ),
        ],
      );
    },
  );
}
