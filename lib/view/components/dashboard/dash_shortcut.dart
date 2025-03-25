import 'package:africanova/database/user.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/bilan/bilan_main.dart';
import 'package:africanova/view/components/security/role_and_permission.dart';
import 'package:africanova/view/components/services/service_saver.dart';
import 'package:africanova/view/components/ventes/vente_saver.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class DashShortcut extends StatelessWidget {
  final Function(Widget) switchView;
  const DashShortcut({super.key, required this.switchView});

  @override
  Widget build(BuildContext context) {
    final user = Hive.box<User>('userBox').get('currentUser');
    return Column(
      children: [
        SizedBox(
          height: 60.0,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
            ),
            elevation: 0.0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8.0,
                      children: [
                        CircleAvatar(
                          child: Icon(
                            Icons.account_circle_rounded,
                            color: Provider.of<ThemeProvider>(context)
                                .themeData
                                .colorScheme
                                .tertiary,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${user!.employer!.prenom} ${user.employer!.nom}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${user.employer!.contact} | ${user.employer!.adresse}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<Map<String, bool>>(
                    future: checkPermissions([
                      'enregistrer ventes',
                      'enregistrer services',
                      'voir factures',
                      'faire bilan',
                      'voir commandes',
                      'voir clients',
                      'voir dashboard',
                      'gestion autorisations',
                      'corbeille',
                      'paramètres',
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      }

                      var permissions = snapshot.data ?? {};

                      return Wrap(
                        children: [
                          if (permissions['enregistrer ventes'] ?? false)
                            SizedBox(
                              height: 35,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor:
                                      Provider.of<ThemeProvider>(context)
                                          .themeData
                                          .colorScheme
                                          .primary,
                                  foregroundColor:
                                      Provider.of<ThemeProvider>(context)
                                          .themeData
                                          .colorScheme
                                          .tertiary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                ),
                                onPressed: () {
                                  switchView(VenteSaver());
                                },
                                icon: Icon(
                                  Icons.sell,
                                  color: Provider.of<ThemeProvider>(context)
                                      .themeData
                                      .colorScheme
                                      .tertiary,
                                ),
                                label: const Text(
                                  'Vente',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          if (permissions['enregistrer services'] ?? false) ...[
                            SizedBox(width: 8.0),
                            SizedBox(
                              height: 35,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor:
                                      Provider.of<ThemeProvider>(context)
                                          .themeData
                                          .colorScheme
                                          .primary,
                                  foregroundColor:
                                      Provider.of<ThemeProvider>(context)
                                          .themeData
                                          .colorScheme
                                          .tertiary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                ),
                                onPressed: () {
                                  switchView(ServiceSaver());
                                },
                                icon: Icon(
                                  Icons.computer_rounded,
                                  color: Provider.of<ThemeProvider>(context)
                                      .themeData
                                      .colorScheme
                                      .tertiary,
                                ),
                                label: const Text(
                                  'Service',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (permissions['faire bilan'] ?? false) ...[
                            SizedBox(width: 8.0),
                            SizedBox(
                              height: 35,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor:
                                      Provider.of<ThemeProvider>(context)
                                          .themeData
                                          .colorScheme
                                          .primary,
                                  foregroundColor:
                                      Provider.of<ThemeProvider>(context)
                                          .themeData
                                          .colorScheme
                                          .tertiary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                ),
                                onPressed: () {
                                  switchView(BilanMain(switchView: switchView));
                                },
                                icon: Icon(
                                  Icons.summarize_outlined,
                                  color: Provider.of<ThemeProvider>(context)
                                      .themeData
                                      .colorScheme
                                      .tertiary,
                                ),
                                label: const Text(
                                  'Bilan',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (permissions['gestion autorisations'] ??
                              false) ...[
                            SizedBox(width: 8.0),
                            SizedBox(
                              height: 35,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor:
                                      Provider.of<ThemeProvider>(context)
                                          .themeData
                                          .colorScheme
                                          .primary,
                                  foregroundColor:
                                      Provider.of<ThemeProvider>(context)
                                          .themeData
                                          .colorScheme
                                          .tertiary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RoleAndPermission(),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.security,
                                  color: Provider.of<ThemeProvider>(context)
                                      .themeData
                                      .colorScheme
                                      .tertiary,
                                ),
                                label: const Text(
                                  'Autorisations',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (permissions['voir dashboard'] ?? false) ...[
                            SizedBox(width: 8.0),
                            SizedBox(
                              height: 35,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor:
                                      Provider.of<ThemeProvider>(context)
                                          .themeData
                                          .colorScheme
                                          .primary,
                                  foregroundColor:
                                      Provider.of<ThemeProvider>(context)
                                          .themeData
                                          .colorScheme
                                          .tertiary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                ),
                                onPressed: () {
                                  switchView(Placeholder());
                                },
                                icon: Icon(
                                  Icons.table_chart,
                                  color: Provider.of<ThemeProvider>(context)
                                      .themeData
                                      .colorScheme
                                      .tertiary,
                                ),
                                label: const Text(
                                  'Plus de statistiques',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // SizedBox(
        //   height: 100.0,
        //   child: Card(
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(2.0),
        //     ),
        //     elevation: 0.0,
        //     child: Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         children: [
        //           FutureBuilder<Map<String, bool>>(
        //             future: checkPermissions([
        //               'enregistrer ventes',
        //               'voir factures',
        //               'voir bilan',
        //               'voir commandes',
        //               'voir clients',
        //               'voir vendeurs',
        //               'gestion autorisations',
        //               'corbeille',
        //               'paramètres',
        //             ]),
        //             builder: (context, snapshot) {
        //               if (snapshot.connectionState == ConnectionState.waiting) {
        //                 return const Center(child: CircularProgressIndicator());
        //               }
        //               if (snapshot.hasError) {
        //                 return Center(child: Text('Erreur: ${snapshot.error}'));
        //               }

        //               var permissions = snapshot.data ?? {};

        //               return Wrap(
        //                 children: [
        //                   if (permissions['enregistrer ventes'] ?? false)
        //                     SizedBox(
        //                       height: 35,
        //                       child: TextButton.icon(
        //                         style: TextButton.styleFrom(
        //                           elevation: 0.0,
        //                           backgroundColor:
        //                               Provider.of<ThemeProvider>(context)
        //                                   .themeData
        //                                   .colorScheme
        //                                   .primary,
        //                           foregroundColor:
        //                               Provider.of<ThemeProvider>(context)
        //                                   .themeData
        //                                   .colorScheme
        //                                   .tertiary,
        //                           shape: RoundedRectangleBorder(
        //                             borderRadius: BorderRadius.circular(2.0),
        //                           ),
        //                         ),
        //                         onPressed: () {
        //                           switchView(VenteSaver());
        //                         },
        //                         icon: Icon(
        //                           Icons.sell,
        //                           color: Provider.of<ThemeProvider>(context)
        //                               .themeData
        //                               .colorScheme
        //                               .tertiary,
        //                         ),
        //                         label: const Text(
        //                           'Vente',
        //                           maxLines: 1,
        //                           overflow: TextOverflow.ellipsis,
        //                           style: TextStyle(
        //                             fontSize: 16,
        //                             fontWeight: FontWeight.w600,
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                   SizedBox(width: 16.0),
        //                   if (permissions['gestion autorisations'] ?? false)
        //                     SizedBox(
        //                       height: 35,
        //                       child: TextButton.icon(
        //                         style: TextButton.styleFrom(
        //                           elevation: 0.0,
        //                           backgroundColor:
        //                               Provider.of<ThemeProvider>(context)
        //                                   .themeData
        //                                   .colorScheme
        //                                   .primary,
        //                           foregroundColor:
        //                               Provider.of<ThemeProvider>(context)
        //                                   .themeData
        //                                   .colorScheme
        //                                   .tertiary,
        //                           shape: RoundedRectangleBorder(
        //                             borderRadius: BorderRadius.circular(2.0),
        //                           ),
        //                         ),
        //                         onPressed: () {
        //                           Navigator.push(
        //                             context,
        //                             MaterialPageRoute(
        //                               builder: (context) => RoleAndPermission(),
        //                             ),
        //                           );
        //                         },
        //                         icon: Icon(
        //                           Icons.security,
        //                           color: Provider.of<ThemeProvider>(context)
        //                               .themeData
        //                               .colorScheme
        //                               .tertiary,
        //                         ),
        //                         label: const Text(
        //                           'Autorisations',
        //                           maxLines: 1,
        //                           overflow: TextOverflow.ellipsis,
        //                           style: TextStyle(
        //                             fontSize: 16,
        //                             fontWeight: FontWeight.w600,
        //                           ),
        //                         ),
        //                       ),
        //                     ),
        //                 ],
        //               );
        //             },
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
