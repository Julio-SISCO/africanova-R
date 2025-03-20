import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/database/approvision.dart';
import 'package:africanova/database/article.dart';
import 'package:africanova/database/categorie.dart';
import 'package:africanova/database/client.dart';
import 'package:africanova/database/employer.dart';
import 'package:africanova/database/fournisseur.dart';
import 'package:africanova/database/outil.dart';
import 'package:africanova/database/permission.dart';
import 'package:africanova/database/service.dart';
import 'package:africanova/database/type_service.dart';
import 'package:africanova/database/vente.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getGlobalData() async {
  try {
    final response = await http.get(
      Uri.parse(Endpoints.global),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['ventes'] != null && responseData['ventes'].isNotEmpty) {
        final List<dynamic> ventesJson = responseData['ventes'];

        List<Vente> ventes = ventesJson
            .map((json) => Vente.fromJson(json as Map<String, dynamic>))
            .toList();

        var box = await Hive.openBox<Vente>('venteHistory');
        await box.clear();

        for (var vente in ventes.reversed) {
          await box.add(vente);
        }
      }
      if (responseData['articles'] != null &&
          responseData['articles'].isNotEmpty) {
        final List<dynamic> articlesJson = responseData['articles'];

        List<Article> articles = articlesJson
            .map((json) => Article.fromJson(json as Map<String, dynamic>))
            .toList();

        var box = await Hive.openBox<Article>('articleBox');
        await box.clear();

        for (var article in articles.reversed) {
          await box.add(article);
        }
      }
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
      if (responseData['clients'] != null &&
          responseData['clients'].isNotEmpty) {
        final List<dynamic> clientsJson = responseData['clients'];

        List<Client> clients = clientsJson
            .map((json) => Client.fromJson(json as Map<String, dynamic>))
            .toList();

        var box = await Hive.openBox<Client>('clientBox');
        await box.clear();

        for (var client in clients.reversed) {
          await box.add(client);
        }
      }
      if (responseData['employers'] != null &&
          responseData['employers'].isNotEmpty) {
        final List<dynamic> employersJson = responseData['employers'];

        List<Employer> employers = employersJson
            .map((json) => Employer.fromJson(json as Map<String, dynamic>))
            .toList();

        var box = await Hive.openBox<Employer>('employerBox');
        await box.clear();

        for (var employer in employers.reversed) {
          await box.add(employer);
        }
      }
      if (responseData['fournisseurs'] != null &&
          responseData['fournisseurs'].isNotEmpty) {
        final List<dynamic> fournisseursJson = responseData['fournisseurs'];

        List<Fournisseur> fournisseurs = fournisseursJson
            .map((json) => Fournisseur.fromJson(json as Map<String, dynamic>))
            .toList();

        var box = await Hive.openBox<Fournisseur>('fournisseurBox');
        await box.clear();

        for (var fournisseur in fournisseurs.reversed) {
          await box.add(fournisseur);
        }
      }
      if (responseData['permissions'] != null &&
          responseData['permissions'].isNotEmpty) {
        final List<dynamic> permissionsJson = responseData['permissions'];

        List<Permission> permissions = permissionsJson
            .map((json) => Permission.fromJson(json as Map<String, dynamic>))
            .toList();

        var box = Hive.box<Permission>('userPermissionBox');
        await box.clear();
        for (var permission in permissions) {
          await box.add(permission);
        }
      }
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
      if (responseData['outils'] != null && responseData['outils'].isNotEmpty) {
        final List<dynamic> outilsJson = responseData['outils'];

        List<Outil> outils = outilsJson
            .map((json) => Outil.fromJson(json as Map<String, dynamic>))
            .toList();

        var box = await Hive.openBox<Outil>('outilBox');
        await box.clear();

        for (var outil in outils.reversed) {
          await box.add(outil);
        }
      }
      if (responseData['typeServices'] != null &&
          responseData['typeServices'].isNotEmpty) {
        final List<dynamic> typeServicesJson = responseData['typeServices'];

        List<TypeService> typeServices = typeServicesJson
            .map((json) => TypeService.fromJson(json as Map<String, dynamic>))
            .toList();

        var box = await Hive.openBox<TypeService>('typeServiceBox');
        await box.clear();

        for (var typeService in typeServices.reversed) {
          await box.add(typeService);
        }
      }

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
