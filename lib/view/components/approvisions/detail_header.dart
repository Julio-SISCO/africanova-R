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

  Future<void> _delete(BuildContext context, int id) async {
    final result = await supprimerApprovision(id);
    if (result['status']) {
      Get.back();
      switchView(ApprovisionTable(switchView: switchView));
    }
    Get.snackbar(
      '',
      result["message"],
      titleText: const SizedBox.shrink(),
      messageText: Center(child: Text(result["message"])),
      maxWidth: 300,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String tooltip,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final colorScheme = themeProvider.themeData.colorScheme;
        return Tooltip(
          message: tooltip,
          child: TextButton.icon(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              backgroundColor:
                  const Color.fromARGB(255, 5, 202, 133).withOpacity(0.4),
              foregroundColor: colorScheme.tertiary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0)),
            ),
            icon: Icon(icon, color: colorScheme.tertiary),
            label: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
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

        final permissions = snapshot.data ?? {};

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0)),
              color: themeProvider.themeData.colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _buildButton(
                      context: context,
                      tooltip: "Imprimer la facture",
                      icon: Icons.print,
                      label: "Facture",
                      onPressed: () {},
                    ),
                    if (permissions['supprimer approvisionnements'] ==
                        true) ...[
                      const SizedBox(width: 16.0),
                      _buildButton(
                        context: context,
                        tooltip: "Supprimer",
                        icon: Icons.delete,
                        label: "Supprimer",
                        onPressed: () {
                          showCancelConfirmationDialog(
                            context,
                            () => _delete(context, approvision.id ?? 0),
                            'Êtes-vous sûr de vouloir supprimer cet approvisionnement ?',
                          );
                        },
                      ),
                    ],
                    if (permissions['modifier approvisionnements'] == true) ...[
                      const SizedBox(width: 16.0),
                      _buildButton(
                        context: context,
                        tooltip: "Modifier",
                        icon: Icons.edit,
                        label: "Modifier",
                        onPressed: () => switchView(
                            ApprovisionSaver(editableApprovision: approvision)),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
