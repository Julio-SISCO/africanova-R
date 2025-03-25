import 'package:africanova/controller/permissions_controller.dart';
import 'package:africanova/database/permission.dart';
import 'package:africanova/database/role.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class EditRoleForm extends StatefulWidget {
  final Role role;
  const EditRoleForm({super.key, required this.role});

  @override
  State<EditRoleForm> createState() => _EditRoleFormState();
}

class _EditRoleFormState extends State<EditRoleForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _roleNameController = TextEditingController();
  List<String> _selectedPermissions = [];
  List<Permission> _availablePermissions = [];
  bool loading = false;
  @override
  void initState() {
    super.initState();
    _roleNameController.text = widget.role.name;
    _selectedPermissions = widget.role.permissions.map((p) => p.name).toList();
    loadPermissions();
  }

  void loadPermissions() {
    var box = Hive.box<Permission>('permissionBox');

    setState(() {
      _availablePermissions = box.values.toList();
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });

      final result = await updateRole(
        roleId: widget.role.id ?? 0,
        roleName: _roleNameController.text,
        permissions: _selectedPermissions,
      );

      setState(() {
        loading = false;
      });

      if (result['status']) {
        Navigator.pop(context, {
          'status': true,
          'roleName': _roleNameController.text,
          'permissions': _selectedPermissions,
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

  void _togglePermission(String permission) {
    setState(() {
      if (_selectedPermissions.contains(permission)) {
        _selectedPermissions.remove(permission);
      } else {
        _selectedPermissions.add(permission);
      }
    });
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
                                value: _selectedPermissions
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
