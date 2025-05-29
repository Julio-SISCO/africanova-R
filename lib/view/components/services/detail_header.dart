import 'package:africanova/controller/service_controller.dart';
import 'package:africanova/database/service.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/services/service_main.dart';
import 'package:africanova/view/components/services/service_saver.dart';
import 'package:africanova/widget/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DetailHeader extends StatelessWidget {
  final Function(Widget) switchView;
  final Service service;
  const DetailHeader({
    super.key,
    required this.service,
    required this.switchView,
  });

  void _delete(context, int id) async {
    final result = await deleteService(id);
    if (result['status']) {
      Get.back();
      switchView(ServiceMain(
        switchView: (Widget w) => switchView(w),
      ));
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

  void _cancel(context, int id) async {
    final result = await cancelService(id);
    if (result['status']) {
      Get.back();
      switchView(ServiceMain(
        switchView: (Widget w) => switchView(w),
      ));
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
        'voir services',
        'annuler services',
        'modifier services',
        'supprimer services',
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
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Tooltip(
                  message: "Imprimer la facture",
                  child: TextButton.icon(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Provider.of<ThemeProvider>(context)
                          .themeData
                          .colorScheme
                          .primary,
                      foregroundColor: Provider.of<ThemeProvider>(context)
                          .themeData
                          .colorScheme
                          .tertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
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
                if (permissions['supprimer services'] ?? false) ...[
                  const SizedBox(width: 16.0),
                  Tooltip(
                    message: "Supprimer",
                    child: TextButton.icon(
                      onPressed: () {
                        showCancelConfirmationDialog(
                          context,
                          () {
                            _delete(context, service.id);
                          },
                          'Êtes-vous sûr de vouloir supprimer ce service ?',
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .primary,
                        foregroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
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
                if (permissions['annuler services'] ?? false) ...[
                  const SizedBox(width: 16.0),
                  Tooltip(
                    message: "Annuler",
                    child: TextButton.icon(
                      onPressed: () {
                        showCancelConfirmationDialog(
                          context,
                          () {
                            _cancel(context, service.id);
                          },
                          'Êtes-vous sûr de vouloir annuler ce service ?',
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .primary,
                        foregroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      icon: Icon(
                        Icons.cancel,
                        color: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .tertiary,
                      ),
                      label: const Text(
                        "Annuler",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                if (permissions['modifier services'] ?? false) ...[
                  const SizedBox(width: 16.0),
                  Tooltip(
                    message: "Mofifier",
                    child: TextButton.icon(
                      onPressed: () {
                        switchView(
                          ServiceSaver(
                            editableService: service,
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .primary,
                        foregroundColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .tertiary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
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
