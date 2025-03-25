import 'package:africanova/controller/permissions_controller.dart';
import 'package:africanova/database/permission.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class RoleForm extends StatefulWidget {
  const RoleForm({super.key});

  @override
  State<RoleForm> createState() => _RoleFormState();
}

class _RoleFormState extends State<RoleForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _roleNameController = TextEditingController();
  List<String> selectedPermissions = [];
  List<Permission> _availablePermissions = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadPermissions();
  }

  Future<void> loadPermissions() async {
    var box = Hive.box<Permission>('permissionBox');

    setState(() {
      _availablePermissions = box.values.toList();
    });
  }

  void _togglePermission(String permission) {
    setState(() {
      if (selectedPermissions.contains(permission)) {
        selectedPermissions.remove(permission);
      } else {
        selectedPermissions.add(permission);
      }
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      final result = await createRole(
        roleName: _roleNameController.text,
        permissions: selectedPermissions,
      );
      setState(() {
        loading = false;
      });
      if (result['status']) {
        Navigator.pop(context, {
          'status': result['status'],
          'roleName': _roleNameController.text,
          'permissions': selectedPermissions,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'].toString()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: TextFormField(
                      controller: _roleNameController,
                      decoration:
                          const InputDecoration(labelText: 'Nom de role'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le nom du rôle est requis.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      elevation: 0.0,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(8),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _availablePermissions.map((permission) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width * 0.20,
                              child: CheckboxListTile(
                                title: Text(
                                  permission.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0,
                                  ),
                                ),
                                value: selectedPermissions
                                    .contains(permission.name),
                                onChanged: (bool? value) {
                                  _togglePermission(permission.name);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Colors.blueGrey[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Annuler',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Colors.green[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: _submitForm,
                          child: Text(
                            'Ajouter',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (loading)
              Container(
                color: Colors.grey.withOpacity(0.2),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
