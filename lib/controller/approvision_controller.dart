import 'dart:async';
import 'dart:io';

import 'package:africanova/database/approvision.dart';
import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Todo: SECTION DE GESTION DES REQUETES VERS API

Future<Map<String, dynamic>> saveApprovision(Approvision approvision) async {
  try {
    final jsonApprovision = json.encode(approvision.toJson());

    // Envoyer une requête POST à l'API
    final response = await http.post(
      Uri.parse(Endpoints.approvision),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonApprovision,
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Approvision>('approvisionBox');
      Approvision approvision0 =
          Approvision.fromJson(responseData['approvision']);

      List<Approvision> existingApprovisions = box.values.toList();

      existingApprovisions = existingApprovisions.reversed.toList();

      existingApprovisions.add(approvision0);

      existingApprovisions = existingApprovisions.reversed.toList();

      await box.clear();
      await box.addAll(existingApprovisions);

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

Future<Map<String, dynamic>> storeApprovision(Approvision approvision) async {
  try {
    final jsonApprovision = json.encode(approvision.toJson());

    // Envoyer une requête POST à l'API
    final response = await http.post(
      Uri.parse(Endpoints.approvision),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonApprovision,
    );

    // Vérifier la réponse du serveur
    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Approvision>('approvisionBox');
      Approvision approvision0 =
          Approvision.fromJson(responseData['approvision']);

      List<Approvision> existingApprovisions = box.values.toList();

      // Inverser la liste des approvisions
      existingApprovisions = existingApprovisions.reversed.toList();

      // Ajouter la nouvelle approvision à la liste inversée
      existingApprovisions.add(approvision0);

      // Inverser la liste des approvisions à nouveau
      existingApprovisions = existingApprovisions.reversed.toList();

      // Vider la boîte et ajouter la nouvelle liste
      await box.clear();
      await box.addAll(existingApprovisions);

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

Future<Map<String, dynamic>> saveEditionApprovision(
    Approvision approvision) async {
  try {
    final jsonApprovision = json.encode(approvision.toJson());

    // Envoyer une requête POST à l'API
    final response = await http.post(
      Uri.parse("${Endpoints.approvision}/${approvision.id}/save"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonApprovision,
    );

    // Vérifier la réponse du serveur
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Approvision>('approvisionBox');
      Approvision approvision0 =
          Approvision.fromJson(responseData['approvision']);
      int? approvisionIndex;

      // Trouver l'index de la approvision à mettre à jour basé sur l'ID
      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == approvision.id) {
          approvisionIndex = i;
          break;
        }
      }
      if (approvisionIndex != null) {
        await box.putAt(approvisionIndex, approvision0);
      } else {
        List<Approvision> existingApprovisions = box.values.toList();
        // Inverser la liste des approvisions
        existingApprovisions = existingApprovisions.reversed.toList();

        // Ajouter la nouvelle approvision à la liste inversée
        existingApprovisions.add(approvision0);

        // Inverser la liste des approvisions à nouveau
        existingApprovisions = existingApprovisions.reversed.toList();

        // Vider la boîte et ajouter la nouvelle liste
        await box.clear();
        await box.addAll(existingApprovisions);
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

Future<Map<String, dynamic>> storeEditionApprovision(
    Approvision approvision) async {
  try {
    final jsonApprovision = json.encode(approvision.toJson());

    // Envoyer une requête POST à l'API
    final response = await http.post(
      Uri.parse("${Endpoints.approvision}/${approvision.id}"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonApprovision,
    );

    // Vérifier la réponse du serveur
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Approvision>('approvisionBox');
      Approvision approvision0 =
          Approvision.fromJson(responseData['approvision']);
      int? approvisionIndex;

      // Trouver l'index de la approvision à mettre à jour basé sur l'ID
      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == approvision.id) {
          approvisionIndex = i;
          break;
        }
      }
      if (approvisionIndex != null) {
        await box.putAt(approvisionIndex, approvision0);
      } else {
        List<Approvision> existingApprovisions = box.values.toList();
        // Inverser la liste des approvisions
        existingApprovisions = existingApprovisions.reversed.toList();

        // Ajouter la nouvelle approvision à la liste inversée
        existingApprovisions.add(approvision0);

        // Inverser la liste des approvisions à nouveau
        existingApprovisions = existingApprovisions.reversed.toList();

        // Vider la boîte et ajouter la nouvelle liste
        await box.clear();
        await box.addAll(existingApprovisions);
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

Future<Map<String, dynamic>> conclureApprovision(int id) async {
  try {
    final response = await http.post(
      Uri.parse('${Endpoints.approvision}/$id/conclure'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Approvision>('approvisionBox');
      Approvision approvision =
          Approvision.fromJson(responseData['approvision']);
      int? approvisionIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          approvisionIndex = i;
          break;
        }
      }
      if (approvisionIndex != null) {
        await box.putAt(approvisionIndex, approvision);
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

Future<Map<String, dynamic>> cancelApprovision(int id) async {
  try {
    final response = await http.post(
      Uri.parse('${Endpoints.approvision}/$id/cancel'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Approvision>('approvisionBox');
      int? approvisionIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          approvisionIndex = i;
          break;
        }
      }
      if (approvisionIndex != null) {
        await box.deleteAt(approvisionIndex);
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

Future<Map<String, dynamic>> updateApprovision(
    Approvision approvision, int id) async {
  final jsonApprovision = json.encode(approvision.toJson());

  // Envoyer une requête PUT à l'API
  final response = await http.put(
    Uri.parse('${Endpoints.approvision}$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await getToken()}',
    },
    body: jsonApprovision,
  );

  final responseData = json.decode(response.body);
  // Vérifier la réponse du serveur
  if (response.statusCode == 200) {
    final box = Hive.box<Approvision>('approvisionBox');
    Approvision approvision0 =
        Approvision.fromJson(responseData['approvision']);
    int? approvisionIndex;

    // Trouver l'index de la approvision à mettre à jour basé sur l'ID
    for (int i = 0; i < box.length; i++) {
      if (box.getAt(i)?.id == id) {
        approvisionIndex = i;
        break;
      }
    }
    if (approvisionIndex != null) {
      await box.putAt(approvisionIndex, approvision0);
    }
  }

  return {
    'statusCode': response.statusCode.toString(),
    'message': responseData['message'],
  };
}

Future<Map<String, dynamic>> getApprovision() async {
  try {
    final response = await http.get(
      Uri.parse(Endpoints.approvision),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['approvisions'] != null &&
          responseData['approvisions'].isNotEmpty) {
        final List<dynamic> approvisionsJson = responseData['approvisions'];

        // Mapper les données JSON vers des objets Article
        List<Approvision> approvisions = approvisionsJson
            .map((json) => Approvision.fromJson(json as Map<String, dynamic>))
            .toList();

        // Ouvrir la boîte Hive pour les articles
        var box = await Hive.openBox<Approvision>('approvisionBox');
        await box.clear();

        // Ajouter les nouveaux articles dans la boîte Hive
        for (var approvision in approvisions.reversed) {
          await box.add(approvision);
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

Future<Map<String, dynamic>> supprimerApprovision(int id) async {
  try {
    final String url = '${Endpoints.approvision}/$id';

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Approvision>('approvisionBox');
      int? approvisionIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          approvisionIndex = i;
          break;
        }
      }
      if (approvisionIndex != null) {
        await box.deleteAt(approvisionIndex);
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
