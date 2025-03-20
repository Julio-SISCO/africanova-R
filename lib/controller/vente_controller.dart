import 'dart:async';
import 'dart:io';

import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/database/vente.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> sendVente(Vente vente) async {
  try {
    final jsonVente = json.encode(vente.toJson());

    // Envoyer une requête POST à l'API
    final response = await http.post(
      Uri.parse(Endpoints.vente),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonVente,
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Vente>('venteHistory');
      Vente vente0 = Vente.fromJson(responseData['vente']);

      List<Vente> existingVentes = box.values.toList();

      existingVentes = existingVentes.reversed.toList();

      existingVentes.add(vente0);

      existingVentes = existingVentes.reversed.toList();

      await box.clear();
      await box.addAll(existingVentes);

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

Future<Map<String, dynamic>> updateVente(Vente vente, int id) async {
  try {
    final jsonVente = json.encode(vente.toJson());

    final response = await http.put(
      Uri.parse('${Endpoints.vente}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonVente,
    );
    // Vérifier la réponse du serveur
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Vente>('venteHistory');
      Vente vente = Vente.fromJson(responseData['vente']);
      int? venteIndex;

      // Trouver l'index de la vente à mettre à jour basé sur l'ID
      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          venteIndex = i;
          break;
        }
      }
      if (venteIndex != null) {
        await box.putAt(venteIndex, vente);
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

Future<Map<String, dynamic>> cancelVente(int id) async {
  try {
    final response = await http.post(
      Uri.parse('${Endpoints.vente}/$id/cancel'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Vente>('venteHistory');
      int? venteIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          venteIndex = i;
          break;
        }
      }
      Vente vente = Vente.fromJson(responseData['vente']);
      if (venteIndex != null) {
        await box.putAt(venteIndex, vente);
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

Future<Map<String, dynamic>> deleteVente(int id) async {
  try {
    final response = await http.delete(
      Uri.parse('${Endpoints.vente}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Vente>('venteHistory');
      int? venteIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          venteIndex = i;
          break;
        }
      }
      if (venteIndex != null) {
        await box.deleteAt(venteIndex);
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

Future<Map<String, dynamic>> getVente() async {
  try {
    final response = await http.get(
      Uri.parse(Endpoints.vente),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['ventes'] != null && responseData['ventes'].isNotEmpty) {
        final List<dynamic> ventesJson = responseData['ventes'];

        // Mapper les données JSON vers des objets Article
        List<Vente> ventes = ventesJson
            .map((json) => Vente.fromJson(json as Map<String, dynamic>))
            .toList();

        // Ouvrir la boîte Hive pour les articles
        var box = await Hive.openBox<Vente>('venteHistory');
        await box.clear();

        // Ajouter les nouveaux articles dans la boîte Hive
        for (var vente in ventes.reversed) {
          await box.add(vente);
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
