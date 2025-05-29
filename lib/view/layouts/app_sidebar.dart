import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/articles/article_table.dart';
import 'package:africanova/view/components/categories/categorie_table.dart';
import 'package:africanova/view/components/clients/client_table.dart';
import 'package:africanova/view/components/dashboard/dashboard.dart';
import 'package:africanova/view/components/depenses/depense_page.dart';
import 'package:africanova/view/components/employers/employer_table.dart';
import 'package:africanova/view/components/fournisseurs/fournisseur_table.dart';
import 'package:africanova/view/components/security/role_and_permission.dart';
import 'package:africanova/view/components/services/service_main.dart';
import 'package:africanova/view/components/ventes/vente_table.dart';
import 'package:africanova/widget/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppSidebar extends StatefulWidget {
  final Function(Widget) switchView;
  final List<String> userPermissions;
  const AppSidebar({super.key, required this.switchView, required this.userPermissions});

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  int index = 0;

  Widget buildMenu(String title, IconData icon, int menuIndex, Widget view, {required String permission}) {
    if (!widget.userPermissions.contains(permission)) {
      return const SizedBox.shrink();
    }
    return Menu(
      title: title,
      press: () {
        setState(() => index = menuIndex);
        widget.switchView(view);
      },
      isSelected: index == menuIndex,
      icon: Icon(icon, size: 16),
    );
  }

  Widget buildMenuDrop(String title, IconData icon, List<Widget> menus, bool isSelected) {
    if (menus.whereType<Menu>().isEmpty) {
      return const SizedBox.shrink();
    }
    return MenuDrop(
      title: title,
      icon: Icon(icon),
      isSelected: isSelected,
      menus: menus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).themeData.colorScheme;

    return Card(
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      color: theme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    HeadMenu(),
                    Divider(color: theme.primary),
                    buildMenu(
                      'Tableau de Bord',
                      Icons.widgets_rounded,
                      0,
                      Dashboard(switchView: widget.switchView),
                      permission: 'voir dashboard',
                    ),
                    const SizedBox(height: 8.0),
                    buildMenuDrop(
                      'Activités',
                      Icons.access_time_rounded,
                      [
                        buildMenu(
                          'Ventes',
                          Icons.sell,
                          1,
                          VenteTable(switchView: widget.switchView),
                          permission: 'voir ventes',
                        ),
                        buildMenu(
                          'Services',
                          Icons.computer_rounded,
                          2,
                          ServiceMain(switchView: widget.switchView),
                          permission: 'voir services',
                        ),
                        buildMenu(
                          'Commandes',
                          Icons.domain_verification_rounded,
                          3,
                          const Placeholder(),
                          permission: 'voir commandes',
                        ),
                      ],
                      index == 1 || index == 2 || index == 3,
                    ),
                    const SizedBox(height: 8.0),
                    buildMenuDrop(
                      'Boutique',
                      Icons.shopify,
                      [
                        buildMenu(
                          'Catégories',
                          Icons.category,
                          5,
                          CategorieTable(switchView: widget.switchView),
                          permission: 'voir categories',
                        ),
                        buildMenu(
                          'Articles',
                          Icons.add_to_photos,
                          6,
                          ArticleTable(switchView: widget.switchView),
                          permission: 'voir articles',
                        ),
                      ],
                      index == 5 || index == 6,
                    ),
                    const SizedBox(height: 8.0),
                    buildMenuDrop(
                      'Personnels',
                      Icons.groups_2,
                      [
                        buildMenu(
                          'Employers',
                          Icons.person,
                          7,
                          EmployerTable(switchView: widget.switchView),
                          permission: 'voir employers',
                        ),
                        buildMenu(
                          'Clients',
                          Icons.people,
                          8,
                          ClientTable(switchView: widget.switchView),
                          permission: 'voir clients',
                        ),
                        buildMenu(
                          'Fournisseurs',
                          Icons.store,
                          9,
                          FournisseurTable(switchView: widget.switchView),
                          permission: 'voir fournisseurs',
                        ),
                      ],
                      index == 7 || index == 8 || index == 9,
                    ),
                    const SizedBox(height: 8.0),
                    buildMenuDrop(
                      'Finances',
                      Icons.attach_money,
                      [
                        buildMenu(
                          'Dépenses',
                          Icons.trending_down,
                          10,
                          DepensePage(switchView: widget.switchView),
                          permission: 'voir depenses',
                        ),
                        buildMenu(
                          'Revenus',
                          Icons.trending_up,
                          11,
                          const Placeholder(),
                          permission: 'voir revenus',
                        ),
                      ],
                      index == 10 || index == 11,
                    ),
                    const SizedBox(height: 8.0),
                    buildMenuDrop(
                      'Autres',
                      Icons.more_horiz,
                      [
                        buildMenu(
                          'Autorisations',
                          Icons.security,
                          12,
                          RoleAndPermission(),
                          permission: 'gestion autorisations',
                        ),
                      ],
                      index == 12,
                    ),
                  ],
                ),
              ),
            ),
            Align(alignment: Alignment.bottomCenter, child: FootMenu()),
          ],
        ),
      ),
    );
  }
}
