import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/database/bilan.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getBilan({
  int? article,
  DateTime? startDate,
  DateTime? endDate,
}) async {
  // Construction de la base de l'URL
  final link = Uri.parse(
      article == null ? Endpoints.bilan : "${Endpoints.bilan}/$article");

  // Construction des paramètres de requête
  final queryParams = <String, String>{};

  // Ajouter les paramètres date si non nuls
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
      if (responseData['bilan'] != null && responseData['bilan'].isNotEmpty) {
        final List<dynamic> topsJson = responseData['bilan'];

        List<Bilan> bilans = topsJson
            .map((json) => Bilan.fromJson(json as Map<String, dynamic>))
            .toList();

        var box = Hive.box<Bilan>('bilanBox');
        await box.clear();

        for (var bilan in bilans) {
          await box.add(bilan);
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
