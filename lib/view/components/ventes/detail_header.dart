import 'package:africanova/controller/vente_controller.dart';
import 'package:africanova/database/vente.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/ventes/vente_saver.dart';
import 'package:africanova/view/components/ventes/vente_table.dart';
import 'package:africanova/widget/dialogs.dart';
import 'package:africanova/widget/pdf/facture_vente_pdf.dart';
import 'package:africanova/widget/pdf/pdf_config.dart';
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

  Future<void> _handleAction(
    BuildContext context,
    Future<Map<String, dynamic>> Function() action,
    String message,
  ) async {
    final result = await action();
    if (result['status']) {
      Get.back();
      switchView(VenteTable(switchView: switchView));
    }
    Get.snackbar(
      '',
      result['message'],
      titleText: const SizedBox.shrink(),
      messageText: Center(child: Text(result['message'])),
      maxWidth: 300,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    final theme = Provider.of<ThemeProvider>(context).themeData.colorScheme;
    return Tooltip(
      message: tooltip,
      child: Center(
        child: TextButton.icon(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            elevation: 0,
            backgroundColor: theme.primary,
            foregroundColor: theme.tertiary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          ),
          icon: Icon(icon, color: theme.tertiary),
          label: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, bool>>(
      future: checkPermissions(
          ['modifier ventes', 'supprimer ventes', 'annuler ventes']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final permissions = snapshot.data ?? {};
        final buttons = <Widget>[
          _buildButton(
            context: context,
            label: "Facture",
            icon: Icons.print,
            tooltip: "Imprimer la facture",
            onPressed: () async {
              await printDoc(
                generatePDF: () => factureVente(vente),
                nomDoc: "Facture ${vente.numFacture}",
                path: "Factures/Ventes",
              );
            },
          ),
        ];

        if (permissions['supprimer ventes'] ?? false) {
          buttons.addAll([
            const SizedBox(width: 16),
            _buildButton(
              context: context,
              label: "Supprimer",
              icon: Icons.delete,
              tooltip: "Supprimer",
              onPressed: () => showCancelConfirmationDialog(
                context,
                () => _handleAction(context, () => deleteVente(vente.id ?? 0),
                    'Suppression...'),
                'Êtes-vous sûr de vouloir supprimer cette vente ?',
              ),
            ),
          ]);
        }

        if (permissions['annuler ventes'] ?? false) {
          buttons.addAll([
            const SizedBox(width: 16),
            _buildButton(
              context: context,
              label: "Annuler",
              icon: Icons.cancel,
              tooltip: "Annuler la vente",
              onPressed: () => showCancelConfirmationDialog(
                context,
                () => _handleAction(
                    context, () => cancelVente(vente.id ?? 0), 'Annulation...'),
                'Êtes-vous sûr de vouloir annuler cette vente ?',
              ),
            ),
          ]);
        }

        if (permissions['modifier ventes'] ?? false) {
          buttons.addAll([
            const SizedBox(width: 16),
            _buildButton(
              context: context,
              label: "Modifier",
              icon: Icons.edit,
              tooltip: "Modifier",
              onPressed: () => switchView(VenteSaver(editableVente: vente)),
            ),
          ]);
        }

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: buttons),
          ),
        );
      },
    );
  }
}
