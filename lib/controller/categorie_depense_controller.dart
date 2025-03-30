import 'dart:async';
import 'dart:io';

import 'package:africanova/database/categorie_depense.dart';
import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> sendCategorieDepense(
    {required CategorieDepense categorieDepense}) async {
  try {
    final jsonCategorieDepense = json.encode(categorieDepense.toJson());

    // Envoyer une requête POST à l'API
    final response = await http.post(
      Uri.parse(Endpoints.categorieDepense),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonCategorieDepense,
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final box = Hive.box<CategorieDepense>('categorieDepenseBox');
      CategorieDepense categorieDepense0 =
          CategorieDepense.fromJson(responseData['categorie']);

      List<CategorieDepense> existingCategorieDepenses = box.values.toList();

      existingCategorieDepenses = existingCategorieDepenses.reversed.toList();

      existingCategorieDepenses.add(categorieDepense0);

      existingCategorieDepenses = existingCategorieDepenses.reversed.toList();

      await box.clear();
      await box.addAll(existingCategorieDepenses);

      return {
        'status': responseData['status'],
        'message': responseData['message'],
      };
    } else if (response.statusCode == 400) {
      final responseData = json.decode(response.body);
      return {
        'status': false,
        'message': responseData['error'],
      };
    } else {
      return {
        'status': false,
        'message': response.statusCode.toString(),
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

Future<Map<String, dynamic>> updateCategorieDepense(
    {required CategorieDepense categorieDepense, required int id}) async {
  try {
    final jsonCategorieDepense = json.encode(categorieDepense.toJson());

    final response = await http.put(
      Uri.parse('${Endpoints.categorieDepense}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonCategorieDepense,
    );
    // Vérifier la réponse du serveur
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<CategorieDepense>('categorieDepenseBox');
      CategorieDepense categorieDepense =
          CategorieDepense.fromJson(responseData['categorie']);
      int? categorieDepenseIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          categorieDepenseIndex = i;
          break;
        }
      }
      if (categorieDepenseIndex != null) {
        await box.putAt(categorieDepenseIndex, categorieDepense);
      }

      return {
        'status': responseData['status'],
        'message': responseData['message'],
      };
    } else if (response.statusCode == 400) {
      final responseData = json.decode(response.body);
      return {
        'status': false,
        'message': responseData['error'],
      };
    } else {
      return {
        'status': false,
        'message': response.statusCode.toString(),
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

Future<Map<String, dynamic>> deleteCategorieDepense(int id) async {
  try {
    final response = await http.delete(
      Uri.parse('${Endpoints.categorieDepense}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<CategorieDepense>('categorieDepenseBox');
      int? categorieDepenseIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          categorieDepenseIndex = i;
          break;
        }
      }
      if (categorieDepenseIndex != null) {
        await box.deleteAt(categorieDepenseIndex);
      }

      return {
        'status': responseData['status'],
        'message': responseData['message'],
      };
    } else if (response.statusCode == 400) {
      final responseData = json.decode(response.body);
      return {
        'status': false,
        'message': responseData['error'],
      };
    } else {
      return {
        'status': false,
        'message': response.statusCode.toString(),
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

Future<Map<String, dynamic>> getCategorieDepense() async {
  try {
    final response = await http.get(
      Uri.parse(Endpoints.categorieDepense),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['categorieDepenses'] != null &&
          responseData['categorieDepenses'].isNotEmpty) {
        final List<dynamic> categorieDepensesJson =
            responseData['categorieDepenses'];

        // Mapper les données JSON vers des objets Article
        List<CategorieDepense> categorieDepenses = categorieDepensesJson
            .map((json) =>
                CategorieDepense.fromJson(json as Map<String, dynamic>))
            .toList();

        // Ouvrir la boîte Hive pour les articles
        var box = await Hive.openBox<CategorieDepense>('categorieDepenseBox');
        await box.clear();

        // Ajouter les nouveaux articles dans la boîte Hive
        for (var categorieDepense in categorieDepenses.reversed) {
          await box.add(categorieDepense);
        }
      }
      return {
        'status': responseData['status'],
        'message': responseData['message'],
      };
    } else if (response.statusCode == 400) {
      final responseData = json.decode(response.body);
      return {
        'status': false,
        'message': responseData['error'],
      };
    } else {
      return {
        'status': false,
        'message': response.statusCode.toString(),
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
