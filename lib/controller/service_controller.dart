import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/database/outil.dart';
import 'package:africanova/database/service.dart';
import 'package:africanova/database/type_service.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> deleteService(int id) async {
  try {
    final response = await http.delete(
      Uri.parse('${Endpoints.service}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Service>('serviceBox');
      int? serviceIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          serviceIndex = i;
          break;
        }
      }
      if (serviceIndex != null) {
        await box.deleteAt(serviceIndex);
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

Future<Map<String, dynamic>> getService() async {
  try {
    final response = await http.get(
      Uri.parse(Endpoints.service),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['services'] != null &&
          responseData['services'].isNotEmpty) {
        final List<dynamic> servicesJson = responseData['services'];

        List<Service> services = servicesJson
            .map((json) => Service.fromJson(json as Map<String, dynamic>))
            .toList();

        var box = await Hive.openBox<Service>('serviceBox');
        await box.clear();

        for (var service in services.reversed) {
          await box.add(service);
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

Future<Map<String, dynamic>> sendService(Service service) async {
  try {
    final jsonService = json.encode(service.toJson());

    final response = await http.post(
      Uri.parse(Endpoints.service),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonService,
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Service>('serviceBox');
      Service service0 = Service.fromJson(responseData['service']);

      List<Service> existingServices = box.values.toList();

      existingServices = existingServices.reversed.toList();

      existingServices.add(service0);

      // Inverser la liste des services à nouveau
      existingServices = existingServices.reversed.toList();

      // Vider la boîte et ajouter la nouvelle liste
      await box.clear();
      await box.addAll(existingServices);

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

Future<Map<String, dynamic>> updateService(Service service, int id) async {
  try {
    final jsonService = json.encode(service.toJson());

    final response = await http.put(
      Uri.parse('${Endpoints.service}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonService,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Service>('serviceBox');
      Service service = Service.fromJson(responseData['service']);
      int? serviceIndex;

      // Trouver l'index de la service à mettre à jour basé sur l'ID
      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          serviceIndex = i;
          break;
        }
      }
      if (serviceIndex != null) {
        await box.putAt(serviceIndex, service);
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

Future<Map<String, dynamic>> cancelService(int id) async {
  try {
    final response = await http.post(
      Uri.parse('${Endpoints.service}/$id/cancel'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Service>('serviceBox');
      int? serviceIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          serviceIndex = i;
          break;
        }
      }
      Service service = Service.fromJson(responseData['service']);
      if (serviceIndex != null) {
        await box.putAt(serviceIndex, service);
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

Future<Map<String, dynamic>> sendOutil(Outil outil) async {
  try {
    final jsonOutil = json.encode(outil.toJson());

    final response = await http.post(
      Uri.parse(Endpoints.outil),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonOutil,
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Outil>('outilBox');
      Outil outil0 = Outil.fromJson(responseData['outil']);

      List<Outil> existingOutils = box.values.toList();

      existingOutils = existingOutils.reversed.toList();

      existingOutils.add(outil0);

      // Inverser la liste des outils à nouveau
      existingOutils = existingOutils.reversed.toList();

      // Vider la boîte et ajouter la nouvelle liste
      await box.clear();
      await box.addAll(existingOutils);

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

Future<Map<String, dynamic>> updateOutil(Outil outil, int id) async {
  try {
    final jsonOutil = json.encode(outil.toJson());

    final response = await http.post(
      Uri.parse('${Endpoints.outil}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonOutil,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Outil>('outilBox');
      Outil outil0 = Outil.fromJson(responseData['outil']);
      int? outilIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          outilIndex = i;
          break;
        }
      }
      if (outilIndex != null) {
        await box.putAt(outilIndex, outil0);
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

Future<Map<String, dynamic>> deleteOutil(int id) async {
  try {
    final response = await http.post(
      Uri.parse('${Endpoints.outil}/$id/delete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<Outil>('outilBox');
      int? outilIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          outilIndex = i;
          break;
        }
      }
      if (outilIndex != null) {
        await box.deleteAt(outilIndex);
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
        'message': '${response.statusCode}',
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

Future<Map<String, dynamic>> sendTypeService(TypeService typeService) async {
  try {
    final jsonTypeService = json.encode(typeService.toJson());

    final response = await http.post(
      Uri.parse(Endpoints.typeService),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonTypeService,
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final box = Hive.box<TypeService>('typeServiceBox');
      TypeService typeService0 = TypeService.fromJson(responseData['type']);

      List<TypeService> existingTypeServices = box.values.toList();

      existingTypeServices = existingTypeServices.reversed.toList();

      existingTypeServices.add(typeService0);

      // Inverser la liste des typeServices à nouveau
      existingTypeServices = existingTypeServices.reversed.toList();

      // Vider la boîte et ajouter la nouvelle liste
      await box.clear();
      await box.addAll(existingTypeServices);

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
      final responseData = json.decode(response.body);
      return {
        'status': false,
        'message': responseData['error'],
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

Future<Map<String, dynamic>> updateTypeService(
    TypeService typeService, int id) async {
  try {
    final jsonTypeService = json.encode(typeService.toJson());

    final response = await http.post(
      Uri.parse('${Endpoints.typeService}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonTypeService,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<TypeService>('typeServiceBox');
      TypeService typeService0 = TypeService.fromJson(responseData['type']);
      int? typeServiceIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          typeServiceIndex = i;
          break;
        }
      }
      if (typeServiceIndex != null) {
        await box.putAt(typeServiceIndex, typeService0);
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

Future<Map<String, dynamic>> deleteTypeService(int id) async {
  try {
    final response = await http.post(
      Uri.parse('${Endpoints.typeService}/$id/delete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final box = Hive.box<TypeService>('typeServiceBox');
      int? typeServiceIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          typeServiceIndex = i;
          break;
        }
      }
      if (typeServiceIndex != null) {
        await box.deleteAt(typeServiceIndex);
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
        'message': '${response.statusCode}',
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
