import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:africanova/controller/auth_controller.dart';
import 'package:africanova/database/categorie.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> storeCategorie({
  String? code,
  required String libelle,
  required String description,
}) async {
  final url = Uri.parse(Endpoints.categorie);

  // Construction du body de la requête en JSON
  try {
    final body = {
      'libelle': libelle,
      'description': description,
    };

    // Ajout du code seulement s'il n'est pas null ou vide
    if (code != null && code.isNotEmpty) {
      body['code'] = code;
    }

    // Envoi de la requête POST
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    final responseData = json.decode(response.body);

    // Vérification de la réponse du serveur
    if (response.statusCode == 201) {
      // Si la réponse est un succès, ajouter la nouvelle catégorie dans Hive
      Categorie categorie = Categorie.fromJson(responseData['categorie']);

      var box = Hive.box<Categorie>('categorieBox');
      List<Categorie> existingCategories = box.values.toList();

      // Inverser la liste des catégories
      existingCategories = existingCategories.reversed.toList();

      // Ajouter la nouvelle catégorie à la liste inversée
      existingCategories.add(categorie);

      // Inverser la liste des articles à nouveau
      existingCategories = existingCategories.reversed.toList();

      // Vider la boîte et ajouter la nouvelle liste
      await box.clear();
      await box.addAll(existingCategories);
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

Future<Map<String, dynamic>> updateCategorie({
  String? code,
  required String libelle,
  required String description,
  required int id,
}) async {
  final url = Uri.parse('${Endpoints.categorie}/$id');

  // Construction du body de la requête en JSON
  try {
    final body = {
      'libelle': libelle,
      'description': description,
    };

    // Ajout du code seulement s'il n'est pas null ou vide
    if (code != null && code.isNotEmpty) {
      body['code'] = code;
    }

    // Envoi de la requête PUT (ou POST si ton API utilise POST pour update)
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    final responseData = json.decode(response.body);

    // Vérification de la réponse du serveur
    if (response.statusCode == 200) {
      // Si la réponse est un succès, mettre à jour la catégorie dans Hive
      Categorie categorie = Categorie.fromJson(responseData['categorie']);

      var box = Hive.box<Categorie>('categorieBox');
      int? categorieIndex;

      // Trouver l'index de la catégorie à mettre à jour basé sur l'ID
      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          categorieIndex = i;
          break;
        }
      }
      if (categorieIndex != null) {
        await box.putAt(categorieIndex, categorie);
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

Future<Map<String, dynamic>> getCategories() async {
  try {
    final url = Uri.parse(Endpoints.categorie);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
        'Content-Type': 'application/json',
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseData['categories'] != null &&
          responseData['categories'].isNotEmpty) {
        final List<dynamic> categoriesJson = responseData['categories'];

        final List<Categorie> categories = categoriesJson.map((json) {
          return Categorie.fromJson(json as Map<String, dynamic>);
        }).toList();

        var box = await Hive.openBox<Categorie>('categorieBox');
        await box.clear();
        for (var categorie in categories.reversed) {
          await box.add(categorie);
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

Future<Map<String, dynamic>> supprimerCategorie(int id) async {
  final String url = '${Endpoints.categorie}/$id';

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
      var box = await Hive.openBox<Categorie>('categorieBox');
      int? categorieIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          categorieIndex = i;
          break;
        }
      }

      if (categorieIndex != null) {
        await box.deleteAt(categorieIndex);
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
        content: Text('Êtes-vous sûr de vouloir supprimer cette categorie ?'),
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
