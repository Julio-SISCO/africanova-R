import 'dart:async';
import 'dart:io';

import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/database/transfert.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> sendTransfert(Transfert transfert) async {
  try {
    final jsonTransfert = json.encode(transfert.toJson());

    final response = await http.post(
      Uri.parse(Endpoints.transfert),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonTransfert,
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Transfert>('transfertsBox');
      Transfert transfert0 = Transfert.fromJson(responseData['transfert']);

      List<Transfert> existingTransferts = box.values.toList();

      existingTransferts = existingTransferts.reversed.toList();

      existingTransferts.add(transfert0);

      existingTransferts = existingTransferts.reversed.toList();

      await box.clear();
      await box.addAll(existingTransferts);

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

Future<Map<String, dynamic>> updateTransfert(
    Transfert transfert, int id) async {
  try {
    final jsonTransfert = json.encode(transfert.toJson());

    final response = await http.put(
      Uri.parse('${Endpoints.transfert}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonTransfert,
    );
    // Vérifier la réponse du serveur
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Transfert>('transfertsBox');
      Transfert transfert = Transfert.fromJson(responseData['transfert']);
      int? transfertIndex;

      // Trouver l'index de la transfert à mettre à jour basé sur l'ID
      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          transfertIndex = i;
          break;
        }
      }
      if (transfertIndex != null) {
        await box.putAt(transfertIndex, transfert);
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

Future<Map<String, dynamic>> cancelTransfert(int id) async {
  try {
    final response = await http.post(
      Uri.parse('${Endpoints.transfert}/$id/cancel'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Transfert>('transfertsBox');
      int? transfertIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          transfertIndex = i;
          break;
        }
      }
      Transfert transfert = Transfert.fromJson(responseData['transfert']);
      if (transfertIndex != null) {
        await box.putAt(transfertIndex, transfert);
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

Future<Map<String, dynamic>> deleteTransfert(int id) async {
  try {
    final response = await http.delete(
      Uri.parse('${Endpoints.transfert}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Transfert>('transfertsBox');
      int? transfertIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          transfertIndex = i;
          break;
        }
      }
      if (transfertIndex != null) {
        await box.deleteAt(transfertIndex);
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

Future<Map<String, dynamic>> getTransfert() async {
  try {
    final response = await http.get(
      Uri.parse(Endpoints.transfert),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['transferts'] != null &&
          responseData['transferts'].isNotEmpty) {
        final List<dynamic> transfertsJson = responseData['transferts'];

        // Mapper les données JSON vers des objets Article
        List<Transfert> transferts = transfertsJson
            .map((json) => Transfert.fromJson(json as Map<String, dynamic>))
            .toList();

        // Ouvrir la boîte Hive pour les articles
        var box = await Hive.openBox<Transfert>('transfertsBox');
        await box.clear();

        // Ajouter les nouveaux articles dans la boîte Hive
        for (var transfert in transferts.reversed) {
          await box.add(transfert);
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
