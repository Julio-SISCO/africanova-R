import 'dart:async';
import 'dart:io';

import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/database/fournisseur.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> sendFournisseur({
  String? adresse,
  String? email,
  String? phone,
  required String fullname,
  required String contact,
}) async {
  final body = {
    'adresse': adresse,
    'email': email,
    'phone': phone,
    'fullname': fullname,
    'contact': contact,
  };

  try {
    final response = await http.post(
      Uri.parse(Endpoints.fournisseur),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    final responseData = json.decode(response.body);
    // Vérification de la réponse du serveur
    if (response.statusCode == 201) {
      Fournisseur fournisseur =
          Fournisseur.fromJson(responseData['fournisseur']);

      var box = Hive.box<Fournisseur>('fournisseurBox');
      List<Fournisseur> existingFournisseurs = box.values.toList();
      // Inverser la liste des fournisseurs
      existingFournisseurs = existingFournisseurs.reversed.toList();
      // Ajouter le nouvel fournisseur à la liste inversée
      existingFournisseurs.add(fournisseur);
      // Inverser la liste des fournisseurs à nouveau
      existingFournisseurs = existingFournisseurs.reversed.toList();
      // Vider la boîte et ajouter la nouvelle liste
      await box.clear();
      await box.addAll(existingFournisseurs);
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

Future<Map<String, dynamic>> updateFournisseur({
  String? adresse,
  String? email,
  String? phone,
  required String fullname,
  required String contact,
  required int id,
}) async {
  final body = {
    'adresse': adresse,
    'email': email,
    'phone': phone,
    'fullname': fullname,
    'contact': contact,
  };

  try {
    final response = await http.put(
      Uri.parse('${Endpoints.fournisseur}/$id'),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    final responseData = json.decode(response.body);
    // Vérification de la réponse du serveur
    if (response.statusCode == 200) {
      Fournisseur fournisseur =
          Fournisseur.fromJson(responseData['fournisseur']);

      var box = Hive.box<Fournisseur>('fournisseurBox');
      int? fournisseurIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          fournisseurIndex = i;
          break;
        }
      }
      if (fournisseurIndex != null) {
        await box.putAt(fournisseurIndex, fournisseur);
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

Future<Map<String, dynamic>> getFournisseurs() async {
  final url = Uri.parse(Endpoints.fournisseur);
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
      // Vérifier si 'fournisseurs' existe et est une liste
      if (responseData['fournisseurs'] != null &&
          responseData['fournisseurs'].isNotEmpty) {
        // Extraire les fournisseurs comme une liste
        final List<dynamic> fournisseursJson = responseData['fournisseurs'];

        // Mapper les données JSON vers des objets Fournisseur
        List<Fournisseur> fournisseurs = fournisseursJson
            .map((json) => Fournisseur.fromJson(json as Map<String, dynamic>))
            .toList();

        // Ouvrir la boîte Hive pour stocker les fournisseurs
        var box = await Hive.openBox<Fournisseur>('fournisseurBox');
        await box.clear();

        // Ajouter les fournisseurs à la boîte Hive
        for (var fournisseur in fournisseurs.reversed) {
          await box.add(fournisseur);
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

Future<Map<String, dynamic>> supprimerFournisseur(int id) async {
  final String url = '${Endpoints.fournisseur}/$id';

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
      var box = await Hive.openBox<Fournisseur>('fournisseurBox');
      int? fournisseurIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          fournisseurIndex = i;
          break;
        }
      }

      if (fournisseurIndex != null) {
        await box.deleteAt(fournisseurIndex);
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
        content: Text('Êtes-vous sûr de vouloir supprimer ce fournisseur ?'),
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
