import 'dart:async';
import 'dart:io';

import 'package:africanova/database/type_depense.dart';
import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> sendTypeDepense(
    {required TypeDepense typeDepense}) async {
  try {
    final jsonTypeDepense = json.encode(typeDepense.toJson());

    // Envoyer une requête POST à l'API
    final response = await http.post(
      Uri.parse(Endpoints.typeDepense),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonTypeDepense,
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final box = Hive.box<TypeDepense>('typeDepenseBox');
      TypeDepense typeDepense0 = TypeDepense.fromJson(responseData['type']);

      List<TypeDepense> existingTypeDepenses = box.values.toList();

      existingTypeDepenses = existingTypeDepenses.reversed.toList();

      existingTypeDepenses.add(typeDepense0);

      existingTypeDepenses = existingTypeDepenses.reversed.toList();

      await box.clear();
      await box.addAll(existingTypeDepenses);

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

Future<Map<String, dynamic>> updateTypeDepense(
    {required TypeDepense typeDepense, required int id}) async {
  try {
    final jsonTypeDepense = json.encode(typeDepense.toJson());

    final response = await http.put(
      Uri.parse('${Endpoints.typeDepense}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonTypeDepense,
    );
    // Vérifier la réponse du serveur
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<TypeDepense>('typeDepenseBox');
      TypeDepense typeDepense = TypeDepense.fromJson(responseData['type']);
      int? typeDepenseIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          typeDepenseIndex = i;
          break;
        }
      }
      if (typeDepenseIndex != null) {
        await box.putAt(typeDepenseIndex, typeDepense);
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

Future<Map<String, dynamic>> deleteTypeDepense(int id) async {
  try {
    final response = await http.delete(
      Uri.parse('${Endpoints.typeDepense}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<TypeDepense>('typeDepenseBox');
      int? typeDepenseIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          typeDepenseIndex = i;
          break;
        }
      }
      if (typeDepenseIndex != null) {
        await box.deleteAt(typeDepenseIndex);
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

Future<Map<String, dynamic>> getTypeDepense() async {
  try {
    final response = await http.get(
      Uri.parse(Endpoints.typeDepense),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['typeDepenses'] != null &&
          responseData['typeDepenses'].isNotEmpty) {
        final List<dynamic> typeDepensesJson = responseData['typeDepenses'];

        // Mapper les données JSON vers des objets Article
        List<TypeDepense> typeDepenses = typeDepensesJson
            .map((json) => TypeDepense.fromJson(json as Map<String, dynamic>))
            .toList();

        // Ouvrir la boîte Hive pour les articles
        var box = await Hive.openBox<TypeDepense>('typeDepenseBox');
        await box.clear();

        // Ajouter les nouveaux articles dans la boîte Hive
        for (var typeDepense in typeDepenses.reversed) {
          await box.add(typeDepense);
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
