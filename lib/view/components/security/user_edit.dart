import 'package:africanova/controller/user_controller.dart';
import 'package:africanova/database/user.dart';
import 'package:africanova/view/components/security/right_card.dart';
import 'package:flutter/material.dart';

class UserEdit extends StatefulWidget {
  final User user;
  final VoidCallback disableAction;
  const UserEdit({super.key, required this.user, required this.disableAction});

  @override
  State<UserEdit> createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  final _formKey = GlobalKey<FormState>();

  List<String> updatedPermissions = [];
  List<String> updatedRoles = [];
  int updatedEmployer = 0;
  String? updatedUsername;
  bool updatedIsActive = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() {
    setState(() {
      updatedIsActive = widget.user.isActive;
      updatedPermissions =
          (widget.user.permissions == null || widget.user.permissions!.isEmpty)
              ? []
              : widget.user.permissions!.map((p) => p.name).toList();
      updatedEmployer = widget.user.employer!.id ?? 0;
      updatedUsername = widget.user.username;

      updatedRoles = (widget.user.roles == null || widget.user.roles!.isEmpty)
          ? []
          : widget.user.roles!.map((p) => p.name).toList();
    });
  }

  void updatePermissions(List<String> updates) {
    setState(() {
      updatedPermissions = updates;
    });
  }

  void updateRoles(List<String> updates) {
    setState(() {
      updatedRoles = updates;
    });
  }

  void updateEmployer(int updates) {
    setState(() {
      updatedEmployer = updates;
    });
  }

  void updateUsername(String updates) {
    setState(() {
      updatedUsername = updates;
    });
  }

  void updateIsActive(bool updates) {
    setState(() {
      updatedIsActive = updates;
    });
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
        Navigator.pop(context);
        widget.disableAction();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(result['message']),
          ),
        ),
      );
    }
  }

  void updateAccount() async {
    if (_formKey.currentState!.validate() &&
        updatedUsername != null &&
        updatedUsername != '') {
      bool confirmUpdate = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Enregistrer les modifications ?'),
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
      if (confirmUpdate) {
        setState(() {
          isLoading = true;
        });
        final result = await updateUser(
          widget.user.id ?? 0,
          updatedUsername ?? '',
          updatedRoles,
          updatedPermissions,
          updatedEmployer,
          updatedIsActive,
        );
        if (result['status']) {
          Navigator.pop(context);
          widget.disableAction();
        }
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(result['message']),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 8.0),
                width: MediaQuery.of(context).size.width,
                color: Colors.grey[100],
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.black,
                        size: 28.0,
                      ),
                      label: const Text(
                        'Fermer',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: updateAccount,
                      icon: Icon(
                        Icons.save,
                        color: Colors.blue[600],
                        size: 28.0,
                      ),
                      label: const Text(
                        'Enregistrer',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        delete(widget.user.id ?? 0);
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 28.0,
                      ),
                      label: const Text(
                        'Supprimer',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            UserInfoCard(
                              user: widget.user,
                              updateUsername: (String update) =>
                                  updateUsername(update),
                              updateEmployer: (int update) =>
                                  updateEmployer(update),
                              updateIsActive: (bool update) =>
                                  updateIsActive(update),
                              formKey: _formKey,
                            ),
                            RoleRightCard(
                              user: widget.user,
                              updateRoles: (List<String> selected) =>
                                  updateRoles(selected),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 1.1,
                          ),
                          child: RightCard(
                            user: widget.user,
                            updatePermissions: (List<String> selected) =>
                                updatePermissions(selected),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.2),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
