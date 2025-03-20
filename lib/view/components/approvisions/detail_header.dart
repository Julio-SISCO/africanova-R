// ignore_for_file: deprecated_member_use

import 'package:africanova/controller/approvision_controller.dart';
import 'package:africanova/database/approvision.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/approvisions/approvision_saver.dart';
import 'package:africanova/view/components/approvisions/approvision_table.dart';
import 'package:africanova/widget/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DetailHeader extends StatelessWidget {
  final Function(Widget) switchView;
  final Approvision approvision;
  const DetailHeader({
    super.key,
    required this.approvision,
    required this.switchView,
  });

  void _delete(context, int id) async {
    final result = await supprimerApprovision(id);
    if (result['status']) {
      Navigator.pop(context);
      switchView(ApprovisionTable(switchView: switchView));
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, bool>>(
      future: checkPermissions([
        'modifier approvisionnements',
        'supprimer approvisionnements',
        'annuler approvisionnements',
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        var permissions = snapshot.data ?? {};

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          elevation: 0.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Tooltip(
                  message: "Imprimer la facture",
                  child: TextButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Provider.of<ThemeProvider>(context)
                          .themeData
                          .colorScheme
                          .primary,
                      foregroundColor: Provider.of<ThemeProvider>(context)
                          .themeData
                          .colorScheme
                          .tertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    icon: Icon(
                      Icons.print,
                      color: Provider.of<ThemeProvider>(context)
                          .themeData
                          .colorScheme
                          .tertiary,
                    ),
                    label: const Text(
                      "Facture",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (permissions['supprimer approvisionnements'] ?? false) ...[
                  const SizedBox(width: 16.0),
                  Tooltip(
                    message: "Supprimer",
                    child: TextButton.icon(
                      onPressed: () {
                        showCancelConfirmationDialog(
                          context,
                          () {
                            _delete(context, approvision.id ?? 0);
                          },
                          'Êtes-vous sûr de vouloir supprimer cet approvisionnement ?',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .primary,
                        foregroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                      icon: Icon(
                        Icons.delete,
                        color: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .tertiary,
                      ),
                      label: const Text(
                        "Supprimer",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                if ((permissions['modifier approvisionnements'] ?? false)) ...[
                  const SizedBox(width: 16.0),
                  Tooltip(
                    message: "Modifier",
                    child: TextButton.icon(
                      onPressed: () {
                        switchView(
                          ApprovisionSaver(
                            editableApprovision: approvision,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .primary,
                        foregroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                      icon: Icon(
                        Icons.edit,
                        color: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .tertiary,
                      ),
                      label: const Text(
                        "Modifier",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
