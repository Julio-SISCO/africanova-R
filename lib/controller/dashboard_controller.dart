import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/database/bilan.dart';
import 'package:africanova/database/top_articles.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getTopArticles() async {
  final url = Uri.parse(Endpoints.topArticles).replace(queryParameters: {
    'limit': '6',
  });
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
      if (responseData['tops'] != null && responseData['tops'].isNotEmpty) {
        final List<dynamic> topsJson = responseData['tops'];

        List<TopArticles> tops = topsJson
            .map((json) => TopArticles.fromJson(json as Map<String, dynamic>))
            .toList();

        var box = Hive.box<TopArticles>('topArticlesBox');
        await box.clear();

        for (var top in tops) {
          await box.add(top);
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

Future<Map<String, dynamic>> getTopVendeurs({
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final link = Uri.parse(Endpoints.topVendeurs);

  final queryParams = <String, String>{};
  queryParams['limit'] = "100";

  if (startDate != null) {
    queryParams['start_date'] = startDate.toIso8601String();
  }
  if (endDate != null) {
    queryParams['end_date'] = endDate.toIso8601String();
  }

  final url = queryParams.isNotEmpty
      ? link.replace(queryParameters: queryParams)
      : link;
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
      if (responseData['tops'] != null && responseData['tops'].isNotEmpty) {
        final List<dynamic> topsJson = responseData['tops'];

        List<TopVendeurs> tops = topsJson
            .map((json) => TopVendeurs.fromJson(json as Map<String, dynamic>))
            .toList();

        var box = Hive.box<TopVendeurs>('topVendeursBox');
        await box.clear();

        for (var top in tops) {
          await box.add(top);
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

Future<Map<String, dynamic>> getSimpleBilan() async {
  final url = Uri.parse(Endpoints.simpleBilan);
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
      final Map<String, dynamic> topsJson = responseData['bilan'];
      var box = Hive.box<Statistique>('statData');
      await box.clear();
      await box.add(Statistique.fromJson(topsJson));
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
