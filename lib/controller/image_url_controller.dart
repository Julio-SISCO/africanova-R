import 'dart:async';
import 'dart:io';

import 'dart:convert';
import 'package:africanova/controller/auth_controller.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:http/http.dart' as http;

String buildUrl(String url) {
  return Endpoints.image + url;
}

Future<Map<String, dynamic>> supprimerImage(int id) async {
  final String url = '${Endpoints.images}/$id';
  final String token = await getToken();

  try {
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final responseData = json.decode(response.body);
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
