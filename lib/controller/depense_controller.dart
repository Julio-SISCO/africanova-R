import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/database/depense.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

Future<Map<String, dynamic>> storeDepense({
  required double montant,
  required DateTime date,
  required String status,
  required String? designation,
  required String? description,
  required int categorie,
  required List<File> fichiers,
}) async {
  final url = Uri.parse(Endpoints.depense);

  try {
    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${await getToken()}'
      ..fields['montant'] = montant.toString()
      ..fields['date'] = date.toIso8601String()
      ..fields['status'] = status
      ..fields['description'] = description ?? ''
      ..fields['designation'] = designation ?? ''
      ..fields['categorie'] = categorie.toString();

    for (File fichier in fichiers) {
      final mimeTypeData = lookupMimeType(fichier.path)?.split('/');
      if (mimeTypeData != null && mimeTypeData.length == 2) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'documents[]',
            fichier.path,
            contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
          ),
        );
      }
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final responseData = json.decode(responseBody);

    if (response.statusCode == 201) {
      Depense depense = Depense.fromJson(responseData['depense']);
      var box = Hive.box<Depense>('depenseBox');
      await box.add(depense);

      return {
        'status': true,
        'message': 'Dépense enregistrée.',
      };
    } else {
      return {
        'status': false,
        'message':
            responseData['message'] ?? 'Erreur lors de l\'enregistrement.',
      };
    }
  } on SocketException {
    return {'status': false, 'message': 'Aucune connexion Internet'};
  } on HttpException {
    return {'status': false, 'message': 'Erreur HTTP.'};
  } on FormatException {
    return {'status': false, 'message': 'Format de réponse non valide.'};
  } on TimeoutException {
    return {
      'status': false,
      'message': 'Délai d\'attente de la requête dépassé.'
    };
  } catch (e) {
    return {'status': false, 'message': 'Erreur inconnue: $e'};
  }
}

Future<Map<String, dynamic>> updateDepense({
  String? code,
  double? prixVente,
  double? prixAchat,
  required String libelle,
  required String designation,
  required String description,
  required int categorie,
  required List<File>? images,
  required int id,
}) async {
  final url = Uri.parse('${Endpoints.depense}/$id');

  try {
    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${await getToken()}'
      ..fields['libelle'] = libelle
      ..fields['description'] = description
      ..fields['categorie_id'] = categorie.toString();

    // Ajout du code seulement s'il n'est pas null ou vide
    if (code != null && code.isNotEmpty) {
      request.fields['code'] = code;
    }

    // Ajout des champs prixAchat et prixVente s'ils ne sont pas null
    if (prixAchat != null) {
      request.fields['prix_achat'] = prixAchat.toString();
    }
    if (prixVente != null) {
      request.fields['prix_vente'] = prixVente.toString();
    }

    // Ajout des fichiers images
    for (File image in images!) {
      final mimeTypeData = lookupMimeType(image.path)?.split('/');
      if (mimeTypeData != null && mimeTypeData.length == 2) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images[]',
            image.path,
            contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
          ),
        );
      }
    }

    // Envoi de la requête
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final responseData = json.decode(responseBody);

    // Vérification de la réponse du serveur
    if (response.statusCode == 200) {
      // Si la réponse est un succès, ajouter le nouvel depense dans Hive
      Depense depense = Depense.fromJson(responseData['depense']);

      var box = Hive.box<Depense>('depenseBox');
      int? depenseIndex;

      // Trouver l'index de l'depense à mettre à jour basé sur l'ID
      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          depenseIndex = i;
          break;
        }
      }
      if (depenseIndex != null) {
        await box.putAt(depenseIndex, depense);
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

Future<Map<String, dynamic>> getDepenses() async {
  try {
    final url = Uri.parse(Endpoints.depense);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
        'Content-Type': 'application/json',
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      // Extraire les valeurs de la liste 'depenses'
      if (responseData['depenses'] != null &&
          responseData['depenses'].isNotEmpty) {
        final List<dynamic> depensesJson = responseData['depenses'];

        // Mapper les données JSON vers des objets Depense
        List<Depense> depenses = depensesJson
            .map((json) => Depense.fromJson(json as Map<String, dynamic>))
            .toList();

        // Ouvrir la boîte Hive pour les depenses
        var box = await Hive.openBox<Depense>('depenseBox');
        await box.clear();

        // Ajouter les nouveaux depenses dans la boîte Hive
        for (var depense in depenses.reversed) {
          await box.add(depense);
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

Future<Map<String, dynamic>> supprimerDepense(int id) async {
  final String url = '${Endpoints.depense}/$id';

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
      var box = await Hive.openBox<Depense>('depenseBox');
      int? depenseIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          depenseIndex = i;
          break;
        }
      }

      if (depenseIndex != null) {
        await box.deleteAt(depenseIndex);
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

Future<Map<String, dynamic>> updateStock(int id, int qte) async {
  final url = Uri.parse('${Endpoints.stock}/$id');
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonEncode({
        'stock': qte,
      }),
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      Depense depense = Depense.fromJson(responseData['depense']);

      var box = Hive.box<Depense>('depenseBox');
      int? depenseIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          depenseIndex = i;
          break;
        }
      }
      if (depenseIndex != null) {
        await box.putAt(depenseIndex, depense);
      }
    }
    return {
      'status': responseData['status'],
      'depense': Depense.fromJson(responseData['depense']),
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
