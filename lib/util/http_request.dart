import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:africanova/provider/auth_provider.dart';
import 'package:http/http.dart' as http;

class HttpRequest {
  static Future<Map<String, dynamic>> securedGetRequest({
    required Uri url,
    String? dataName,
    Function(dynamic)? performData,
  }) async {
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (dataName != null && performData != null) {
          if (data[dataName] != null && data[dataName].isNotEmpty) {
            performData(data[dataName]);
          }
        }
        return {
          'status': data['status'],
          'message': data['message'],
        };
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        return {
          'status': false,
          'message': data['error'],
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
}
