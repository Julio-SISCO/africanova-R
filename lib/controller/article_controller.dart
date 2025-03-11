import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:africanova/controller/auth_controller.dart';
import 'package:africanova/database/article.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

Future<Map<String, dynamic>> storeArticle({
  String? code,
  double? prixVente,
  double? prixAchat,
  required int stock,
  required String libelle,
  required String description,
  required int categorie,
  required List<File> images,
}) async {
  final url = Uri.parse(Endpoints.article);

  try {
    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${await getToken()}'
      ..fields['libelle'] = libelle
      ..fields['description'] = description
      ..fields['stock'] = stock.toString()
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
    for (File image in images) {
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
    if (response.statusCode == 201) {
      // Si la réponse est un succès, ajouter le nouvel article dans Hive
      Article article = Article.fromJson(responseData['article']);

      var box = Hive.box<Article>('articleBox');
      List<Article> existingArticles = box.values.toList();

      // Inverser la liste des articles
      existingArticles = existingArticles.reversed.toList();

      // Ajouter le nouvel article à la liste inversée
      existingArticles.add(article);

      // Inverser la liste des articles à nouveau
      existingArticles = existingArticles.reversed.toList();

      // Vider la boîte et ajouter la nouvelle liste
      await box.clear();
      await box.addAll(existingArticles);
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

Future<Map<String, dynamic>> updateArticle({
  String? code,
  double? prixVente,
  double? prixAchat,
  required String libelle,
  required String description,
  required int categorie,
  required List<File>? images,
  required int id,
}) async {
  final url = Uri.parse('${Endpoints.article}/$id');

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
      // Si la réponse est un succès, ajouter le nouvel article dans Hive
      Article article = Article.fromJson(responseData['article']);

      var box = Hive.box<Article>('articleBox');
      int? articleIndex;

      // Trouver l'index de l'article à mettre à jour basé sur l'ID
      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          articleIndex = i;
          break;
        }
      }
      if (articleIndex != null) {
        await box.putAt(articleIndex, article);
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

Future<Map<String, dynamic>> getArticles() async {
  try {
    final url = Uri.parse(Endpoints.article);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
        'Content-Type': 'application/json',
      },
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      // Extraire les valeurs de la liste 'articles'
      if (responseData['articles'] != null &&
          responseData['articles'].isNotEmpty) {
        final List<dynamic> articlesJson = responseData['articles'];

        // Mapper les données JSON vers des objets Article
        List<Article> articles = articlesJson
            .map((json) => Article.fromJson(json as Map<String, dynamic>))
            .toList();

        // Ouvrir la boîte Hive pour les articles
        var box = await Hive.openBox<Article>('articleBox');
        await box.clear();

        // Ajouter les nouveaux articles dans la boîte Hive
        for (var article in articles.reversed) {
          await box.add(article);
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

Future<Map<String, dynamic>> supprimerArticle(int id) async {
  final String url = '${Endpoints.article}/$id';

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
      var box = await Hive.openBox<Article>('articleBox');
      int? articleIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          articleIndex = i;
          break;
        }
      }

      if (articleIndex != null) {
        await box.deleteAt(articleIndex);
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
        'qte': qte,
      }),
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      Article article = Article.fromJson(responseData['article']);

      var box = Hive.box<Article>('articleBox');
      int? articleIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == id) {
          articleIndex = i;
          break;
        }
      }
      if (articleIndex != null) {
        await box.putAt(articleIndex, article);
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
        content: Text('Êtes-vous sûr de vouloir supprimer cet article ?'),
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

Future<void> showEditStockDialog(
  BuildContext context,
  Article article,
) async {
  final formKey = GlobalKey<FormState>();
  final TextEditingController stockController =
      TextEditingController(text: article.stock?.toString() ?? '0');
  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      final updatedStock = int.parse(stockController.text);
      final result = await updateStock(article.id!, updatedStock);

      Get.snackbar(
        '',
        result["message"],
        titleText: SizedBox.shrink(),
        messageText: Center(
          child: Text(result["message"]),
        ),
        maxWidth: 300,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Modifier la quantité en stock'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: stockController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantité en stock',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer une quantité';
              }
              if (int.tryParse(value) == null) {
                return 'Veuillez entrer un nombre valide';
              }
              if (int.parse(value) < 0) {
                return 'La quantité ne peut pas être négative';
              }
              return null;
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Annuler'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Enregistrer'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await submit();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}
