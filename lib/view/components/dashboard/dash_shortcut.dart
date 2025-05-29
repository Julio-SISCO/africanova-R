import 'package:africanova/database/user.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/bilan/bilan_main.dart';
import 'package:africanova/view/components/transferts/transferer.dart';
import 'package:africanova/view/components/services/service_saver.dart';
import 'package:africanova/view/components/ventes/vente_saver.dart';
import 'package:africanova/widget/app_button.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class DashShortcut extends StatelessWidget {
  final Function(Widget) switchView;
  const DashShortcut({super.key, required this.switchView});

  @override
  Widget build(BuildContext context) {
    final user = Hive.box<User>('userBox').get('currentUser');
    final theme = Provider.of<ThemeProvider>(context).themeData.colorScheme;

    return Column(
      children: [
        SizedBox(
          height: 60.0,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 8.0,
                    children: [
                      CircleAvatar(
                        child: Icon(Icons.account_circle_rounded,
                            color: theme.tertiary),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${user!.employer!.prenom} ${user.employer!.nom}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${user.employer!.contact} | ${user.employer!.adresse}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  FutureBuilder<Map<String, bool>>(
                    future: checkPermissions([
                      'enregistrer ventes',
                      'enregistrer transferts',
                      'enregistrer services',
                      'faire bilan',
                      'voir dashboard',
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(
                            color: theme.secondary);
                      }
                      if (snapshot.hasError) {
                        return Text('Erreur: ${snapshot.error}');
                      }

                      final permissions = snapshot.data ?? {};
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Wrap(
                          spacing: 8.0,
                          children: [
                            buildAccessButton(
                              'Transfert',
                              Icons.share,
                              Transferer(),
                              permissions['enregistrer transferts'] ?? false,
                              switchView,
                            ),
                            buildAccessButton(
                              'Vente',
                              Icons.sell,
                              VenteSaver(),
                              permissions['enregistrer ventes'] ?? false,
                              switchView,
                            ),
                            buildAccessButton(
                              'Service',
                              Icons.computer_rounded,
                              ServiceSaver(),
                              permissions['enregistrer services'] ?? false,
                              switchView,
                            ),
                            buildAccessButton(
                              'Bilan',
                              Icons.summarize_outlined,
                              BilanMain(switchView: switchView),
                              permissions['faire bilan'] ?? false,
                              switchView,
                            ),
                            buildAccessButton(
                              'Plus de statistiques',
                              Icons.table_chart,
                              Placeholder(),
                              permissions['voir dashboard'] ?? false,
                              switchView,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
