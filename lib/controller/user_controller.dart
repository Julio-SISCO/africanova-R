import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/database/user.dart';
import 'package:africanova/static/endpoints.dart';
import 'package:africanova/static/theme.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/view/components/security/user_edit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

Future<Map<String, dynamic>> disableUser(int id) async {
  try {
    final response = await http.post(
      Uri.parse('${Endpoints.user}/$id/disable'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
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

Future<Map<String, dynamic>> enableUser(int id) async {
  try {
    final response = await http.post(
      Uri.parse('${Endpoints.user}/$id/enable'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
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

Future<Map<String, dynamic>> deleteUser(int id) async {
  try {
    final response = await http.post(
      Uri.parse('${Endpoints.user}/$id/delete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
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

Future<Map<String, dynamic>> getUsers() async {
  try {
    final response = await http.get(
      Uri.parse(Endpoints.user),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final usersJson = responseData['users'] as List;

      List<User> users = usersJson
          .map(
            (user) => User.fromJson(user as Map<String, dynamic>),
          )
          .toList();
      var box = Hive.box<User>('otherUser');
      await box.clear();

      for (var user in users) {
        await box.add(user);
      }

      return {
        'status': responseData['status'],
        'message': responseData['message'],
        'users': users,
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

Future<Map<String, dynamic>> updateUser(
  int id,
  String username,
  List<String> roles,
  List<String> permissions,
  int employer,
  bool isActive,
) async {
  try {
    final response = await http.post(
      Uri.parse('${Endpoints.user}/$id/updateAccount'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getToken()}',
      },
      body: json.encode({
        'username': username,
        'employer_id': employer,
        'isActive': isActive,
        'roles': roles,
        'permissions': permissions,
      }),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
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

class UserRolePermissionDataSource extends DataTableSource {
  final List<User> users;
  final int id;
  final BuildContext context;
  final VoidCallback disableAction;

  UserRolePermissionDataSource(
    this.users,
    this.id,
    this.context,
    this.disableAction,
  );
  void disable(int id) async {
    final result = await disableUser(id);

    if (result['status']) {
      disableAction();
    }
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

  void enable(int id) async {
    final result = await enableUser(id);

    if (result['status']) {
      disableAction();
    }
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

  void delete(int id) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Voulez-vous vraiment supprimer ce compte ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      final result = await deleteUser(id);

      if (result['status']) {
        disableAction();
      }

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

  @override
  DataRow getRow(int index) {
    final user = users[index];

    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          return user.id == id ? Colors.blue.shade100 : null;
        },
      ),
      cells: [
        DataCell(
          Center(
            child: CircleAvatar(
              backgroundColor: getRandomColor(),
              radius: 20,
              child: Text(
                user.username[0].toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            user.username,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            user.employer != null
                ? '${user.employer!.prenom} ${user.employer!.nom}'
                : 'Inconnu',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            (user.roles != null && user.roles!.isNotEmpty)
                ? user.roles!.length == 1
                    ? user.roles![0].name
                    : '${user.roles!.length} roles'
                : 'Aucun rôle',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              decoration: (user.roles != null && user.roles!.isNotEmpty)
                  ? null
                  : TextDecoration.underline,
            ),
          ),
        ),
        DataCell(
          Text(
            (user.permissions != null && user.permissions!.isNotEmpty)
                ? user.permissions!.length == 1
                    ? user.permissions![0].name
                    : '${user.permissions!.length} permissions'
                : 'Aucune permission',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              decoration:
                  (user.permissions != null && user.permissions!.isNotEmpty)
                      ? null
                      : TextDecoration.underline,
            ),
          ),
        ),
        DataCell(
          Center(
            child: user.isActive
                ? Icon(
                    Icons.check_circle,
                    color: Colors.green[800],
                  )
                : Icon(
                    Icons.cancel,
                    color: Colors.red[600],
                  ),
          ),
        ),
        DataCell(
          Text(
            DateFormat('dd MMMM yyyy', 'fr').format(user.createdAt!),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Text(
            user.lastLogin == null
                ? 'Aucune activité détectée'
                : formatDate(user.lastLogin),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Wrap(
              children: [
                if (!user.isActive)
                  IconButton(
                    icon: Icon(
                      Icons.check_circle,
                      color: Colors.green[800],
                    ),
                    onPressed: user.id == id
                        ? null
                        : () {
                            enable(user.id ?? 0);
                          },
                  ),
                if (user.isActive)
                  IconButton(
                    icon: Icon(
                      Icons.cancel,
                    ),
                    onPressed: user.id == id
                        ? null
                        : () {
                            disable(user.id ?? 0);
                          },
                  ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: user.id == id ? null : Colors.red[600],
                  ),
                  onPressed: user.id == id
                      ? null
                      : () {
                          delete(user.id ?? 0);
                        },
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.blue[600],
                  ),
                  onPressed: () {
                    // s
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}
