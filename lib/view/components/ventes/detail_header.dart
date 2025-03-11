// ignore_for_file: deprecated_member_use

import 'package:africanova/controller/vente_controller.dart';
import 'package:africanova/database/vente.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/ventes/vente_saver.dart';
import 'package:africanova/view/components/ventes/vente_table.dart';
import 'package:africanova/widget/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DetailHeader extends StatelessWidget {
  final Function(Widget) switchView;
  final Vente vente;
  const DetailHeader({
    super.key,
    required this.vente,
    required this.switchView,
  });

  void _cancel(context, int id) async {
    final result = await cancelVente(id);
    if (result['status']) {
      Navigator.pop(context);
      switchView(VenteTable(switchView: switchView));
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

  void _delete(context, int id) async {
    final result = await deleteVente(id);
    if (result['status']) {
      Navigator.pop(context);
      switchView(VenteTable(switchView: switchView));
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
        'modifier ventes',
        'supprimer ventes',
        'annuler ventes',
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
                if (permissions['supprimer ventes'] ?? false) ...[
                  const SizedBox(width: 16.0),
                  Tooltip(
                    message: "Supprimer",
                    child: TextButton.icon(
                      onPressed: () {
                        showCancelConfirmationDialog(
                          context,
                          () {
                            _delete(context, vente.id ?? 0);
                          },
                          'Êtes-vous sûr de vouloir supprimer cette vente ?',
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
                if (permissions['annuler ventes'] ?? false) ...[
                  const SizedBox(width: 16.0),
                  Tooltip(
                    message: "Annuler la vente",
                    child: TextButton.icon(
                      onPressed: () {
                        showCancelConfirmationDialog(
                          context,
                          () {
                            _cancel(context, vente.id ?? 0);
                          },
                          'Êtes-vous sûr de vouloir annuler cette vente ?',
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
                  )
                ],
                if ((permissions['modifier ventes'] ?? false)) ...[
                  const SizedBox(width: 16.0),
                  Tooltip(
                    message: "Modifier",
                    child: TextButton.icon(
                      onPressed: () {
                        switchView(
                          VenteSaver(
                            editableVente: vente,
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
