import 'package:africanova/controller/user_controller.dart';
import 'package:africanova/database/user.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/security/right_card.dart';
import 'package:africanova/view/components/security/user_role_permission.dart';
import 'package:africanova/widget/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class UserEdit extends StatefulWidget {
  final User user;
  final VoidCallback disableAction;
  final Function(Widget?) switchView;
  const UserEdit({
    super.key,
    required this.user,
    required this.disableAction,
    required this.switchView,
  });

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
    final result = await deleteUser(id);

    if (result['status']) {
      // Get.back();
      // widget.disableAction();
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

  void updateAccount() async {
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
      // Get.back();
      // widget.disableAction();
    }
    setState(() {
      isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          spacing: 4.0,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              margin: EdgeInsets.all(0.0),
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  spacing: 8.0,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildButton(
                      context,
                      "Fermer",
                      Icons.close,
                      () {
                        widget.switchView(
                          UserRolePermission(switchView: widget.switchView),
                        );
                      },
                      null,
                    ),
                    _buildButton(
                      context,
                      "Enregistrer",
                      Icons.save,
                      () {
                        if (_formKey.currentState!.validate() &&
                            updatedUsername != null &&
                            updatedUsername != '') {
                          showCancelConfirmationDialog(
                            context,
                            () {
                              updateAccount();
                            },
                            'Êtes-vous sûr de vouloir modifier ce compte ?',
                          );
                        }
                      },
                      null,
                    ),
                    _buildButton(
                      context,
                      "Supprimer",
                      Icons.delete,
                      () {
                        showCancelConfirmationDialog(
                          context,
                          () {
                            delete(widget.user.id ?? 0);
                          },
                          'Êtes-vous sûr de vouloir supprimer ce compte ?',
                        );
                      },
                      null,
                    ),
                    const SizedBox(width: 16.0),
                  ],
                ),
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
              child: CircularProgressIndicator(
                color: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .secondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String libelle, IconData icon,
      VoidCallback onPressed, Color? color) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SizedBox(
          height: 40,
          width: 120,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor:
                  color ?? themeProvider.themeData.colorScheme.primary,
              foregroundColor: themeProvider.themeData.colorScheme.tertiary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0)),
            ),
            onPressed: onPressed,
            icon: Icon(icon,
                size: 18, color: themeProvider.themeData.colorScheme.tertiary),
            label: Text(
              libelle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        );
      },
    );
  }
}
