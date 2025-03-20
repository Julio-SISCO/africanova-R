import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/database/permission.dart';
import 'package:africanova/database/role.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

Future<Map<String, dynamic>> getMyRoles() async {
  try {
    final response = await http.get(
      Uri.parse('${Endpoints.role}/mine'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final rolesJson = responseData['roles'] as List;
      final permissionsJson = responseData['permissions'] as List;

      List<Role> roles = rolesJson
          .map(
            (role) => Role.fromJson(role as Map<String, dynamic>),
          )
          .toList();
      List<Permission> permissions = permissionsJson
          .map(
            (role) => Permission.fromJson(role as Map<String, dynamic>),
          )
          .toList();

      var box = Hive.box<Role>('roleBox');
      await box.clear();

      for (var role in roles) {
        await box.add(role);
      }

      var box0 = Hive.box<Permission>('permissionBox');
      await box0.clear();

      for (var permission in permissions) {
        await box0.add(permission);
      }

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'roles': roles,
        'permissions': permissions,
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

Future<Map<String, dynamic>> getMyPermissions() async {
  try {
    final url = Uri.parse("${Endpoints.permission}/mine");
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${await getToken()}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
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

Future<Map<String, dynamic>> getRoles() async {
  try {
    final response = await http.get(
      Uri.parse(Endpoints.role),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final rolesJson = responseData['roles'] as List;
      final permissionsJson = responseData['permissions'] as List;

      List<Role> roles = rolesJson
          .map(
            (role) => Role.fromJson(role as Map<String, dynamic>),
          )
          .toList();
      List<Permission> permissions = permissionsJson
          .map(
            (role) => Permission.fromJson(role as Map<String, dynamic>),
          )
          .toList();

      var box = Hive.box<Role>('roleBox');
      await box.clear();

      for (var role in roles) {
        await box.add(role);
      }

      var box0 = Hive.box<Permission>('permissionBox');
      await box0.clear();

      for (var permission in permissions) {
        await box0.add(permission);
      }

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'roles': roles,
        'permissions': permissions,
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

Future<Map<String, dynamic>> createRole({
  required String roleName,
  required List<String> permissions,
}) async {
  try {
    final response = await http.post(
      Uri.parse(Endpoints.role),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonEncode({
        'name': roleName,
        'permissions': permissions,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      Role role = Role.fromJson(responseData['role']);

      var box = Hive.box<Role>('roleBox');
      List<Role> existingRoles = box.values.toList();
      existingRoles = existingRoles.reversed.toList();
      existingRoles.add(role);
      existingRoles = existingRoles.reversed.toList();
      await box.clear();
      await box.addAll(existingRoles);

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'role': role,
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

Future<Map<String, dynamic>> updateRole({
  required int roleId,
  required String roleName,
  required List<String> permissions,
}) async {
  try {
    final response = await http.post(
      Uri.parse("${Endpoints.role}/$roleId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: jsonEncode({
        'name': roleName,
        'permissions': permissions,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      Role role = Role.fromJson(responseData['role']);

      var box = Hive.box<Role>('roleBox');
      int? roleIndex;

      for (int i = 0; i < box.length; i++) {
        if (box.getAt(i)?.id == roleId) {
          roleIndex = i;
          break;
        }
      }
      if (roleIndex != null) {
        await box.putAt(roleIndex, role);
      }

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'role': role,
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
