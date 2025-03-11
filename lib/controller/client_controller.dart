import 'dart:async';
import 'dart:io';

import 'package:africanova/controller/auth_controller.dart';
import 'package:africanova/database/client.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> sendClient({
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
      Uri.parse(Endpoints.client),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 201) {
      Client client = Client.fromJson(responseData['client']);

      var box = Hive.box<Client>('clientBox');
      List<Client> existingClients = box.values.toList();
      existingClients = existingClients.reversed.toList();
      existingClients.add(client);
      existingClients = existingClients.reversed.toList();
      await box.clear();
      await box.addAll(existingClients);
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

Future<Map<String, dynamic>> updateClient({
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
      Uri.parse('${Endpoints.client}/$id'),
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    final responseData = json.decode(response.body);
    // Vérification de la réponse du serveur
    if (response.statusCode == 200) {
      Client client = Client.fromJson(responseData['client']);

      var box = Hive.box<Client>('clientBox');
      int? clientIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          clientIndex = i;
          break;
        }
      }
      if (clientIndex != null) {
        await box.putAt(clientIndex, client);
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

Future<Map<String, dynamic>> getClients() async {
  final url = Uri.parse(Endpoints.client);
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
      // Vérifiez si 'clients' existe et est une liste
      if (responseData['clients'] != null &&
          responseData['clients'].isNotEmpty) {
        // Extraire les clients comme une liste
        final List<dynamic> clientsJson = responseData['clients'];

        // Mapper les données JSON vers des objets Client
        List<Client> clients = clientsJson
            .map((json) => Client.fromJson(json as Map<String, dynamic>))
            .toList();

        // Ouvrir la boîte Hive pour stocker les clients
        var box = await Hive.openBox<Client>('clientBox');
        await box.clear();

        // Ajouter les clients à la boîte Hive
        for (var client in clients.reversed) {
          await box.add(client);
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

Future<Map<String, dynamic>> supprimerClient(int id) async {
  final String url = '${Endpoints.client}/$id';

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
      var box = await Hive.openBox<Client>('clientBox');
      int? clientIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          clientIndex = i;
          break;
        }
      }

      if (clientIndex != null) {
        await box.deleteAt(clientIndex);
        return {
          'status': response.statusCode.toString(),
          'message': json.decode(response.body)['message'] ?? 'Client supprimé',
        };
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
        content: Text('Êtes-vous sûr de vouloir supprimer ce client ?'),
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
