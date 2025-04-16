import 'package:africanova/provider/permissions_providers.dart';
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
  const AppSidebar({super.key, required this.switchView});

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            Provider.of<ThemeProvider>(context).themeData.colorScheme.surface,
        borderRadius: BorderRadius.circular(4.0),
      ),
      padding: EdgeInsets.symmetric(vertical: 16.0),
      margin: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HeadMenu(),
                  Divider(
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .primary,
                  ),
                  Menu(
                    title: 'Tableau de Bord',
                    press: () {
                      setState(() {
                        index = 0;
                      });
                      widget.switchView(
                        Dashboard(
                          switchView: (Widget w) {
                            widget.switchView(w);
                          },
                        ),
                      );
                    },
                    isSelected: index == 0,
                    icon: Icon(Icons.widgets_rounded),
                  ),
                  SizedBox(height: 8.0),
                  MenuDrop(
                    title: 'Activités',
                    icon: Icon(Icons.access_time_rounded),
                    isSelected:
                        index == 3 || index == 1 || index == 2 || index == 4,
                    menus: [
                      buildMenuWithPermission(
                        'voir ventes',
                        Menu(
                          title: 'Ventes',
                          press: () {
                            setState(() {
                              index = 1;
                            });
                            widget.switchView(VenteTable(
                              switchView: (Widget w) {
                                widget.switchView(w);
                              },
                            ));
                          },
                          isSelected: index == 1,
                          icon: Icon(
                            Icons.sell,
                            size: 16,
                          ),
                        ),
                      ),
                      buildMenuWithPermission(
                        'voir services',
                        Menu(
                          title: 'Services',
                          press: () {
                            setState(() {
                              index = 2;
                            });
                            widget.switchView(ServiceMain(
                              switchView: (Widget w) => widget.switchView(w),
                            ));
                          },
                          isSelected: index == 2,
                          icon: Icon(
                            Icons.computer_rounded,
                            size: 16,
                          ),
                        ),
                      ),
                      buildMenuWithPermission(
                        'voir commandes',
                        Menu(
                          title: 'Commandes',
                          press: () {},
                          isSelected: false,
                          icon: Icon(
                            Icons.domain_verification_rounded,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  MenuDrop(
                    title: 'Boutique',
                    icon: Icon(Icons.shopify),
                    isSelected: index == 5 || index == 6,
                    menus: [
                      buildMenuWithPermission(
                        'voir categories',
                        Menu(
                          title: 'Catégories',
                          press: () {
                            setState(() {
                              index = 5;
                            });
                            widget.switchView(CategorieTable(
                              switchView: (Widget w) {
                                widget.switchView(w);
                              },
                            ));
                          },
                          isSelected: index == 5,
                          icon: Icon(
                            Icons.category,
                            size: 16,
                          ),
                        ),
                      ),
                      buildMenuWithPermission(
                        'voir articles',
                        Menu(
                          title: 'Articles',
                          press: () {
                            setState(() {
                              index = 6;
                            });
                            widget.switchView(ArticleTable(
                              switchView: (Widget w) {
                                widget.switchView(w);
                              },
                            ));
                          },
                          isSelected: index == 6,
                          icon: Icon(
                            Icons.add_to_photos,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  MenuDrop(
                    title: 'Personnels',
                    icon: Icon(Icons.groups_2),
                    isSelected: index == 7 || index == 8 || index == 9,
                    menus: [
                      buildMenuWithPermission(
                        'voir employers',
                        Menu(
                          title: 'Employers',
                          press: () {
                            setState(() {
                              index = 7;
                            });
                            widget.switchView(EmployerTable(
                              switchView: (Widget w) {
                                widget.switchView(w);
                              },
                            ));
                          },
                          isSelected: index == 7,
                          icon: Icon(
                            Icons.person,
                            size: 16,
                          ),
                        ),
                      ),
                      buildMenuWithPermission(
                        'voir clients',
                        Menu(
                          title: 'Clients',
                          press: () {
                            setState(() {
                              index = 8;
                            });
                            widget.switchView(ClientTable(
                              switchView: (Widget w) {
                                widget.switchView(w);
                              },
                            ));
                          },
                          isSelected: index == 8,
                          icon: Icon(
                            Icons.people,
                            size: 16,
                          ),
                        ),
                      ),
                      buildMenuWithPermission(
                        'voir fournisseurs',
                        Menu(
                          title: 'Fournisseurs',
                          press: () {
                            setState(() {
                              index = 9;
                            });
                            widget.switchView(FournisseurTable(
                              switchView: (Widget w) {
                                widget.switchView(w);
                              },
                            ));
                          },
                          isSelected: index == 9,
                          icon: Icon(
                            Icons.store,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  MenuDrop(
                    title: 'Finances',
                    icon: const Icon(Icons.attach_money),
                    isSelected: index == 10 || index == 11,
                    menus: [
                      buildMenuWithPermission(
                        'voir depenses',
                        Menu(
                          title: 'Dépenses',
                          press: () {
                            setState(() {
                              index = 10;
                            });
                            widget.switchView(
                              DepensePage(
                                switchView: (Widget w) {
                                  widget.switchView(w);
                                },
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.trending_down,
                            size: 16,
                          ),
                          isSelected: index == 10,
                        ),
                      ),
                      Menu(
                        title: 'Revenus',
                        press: () {},
                        icon: const Icon(
                          Icons.trending_up,
                          size: 16,
                        ),
                        isSelected: false,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  MenuDrop(
                    title: 'Autres',
                    icon: Icon(Icons.more_horiz),
                    isSelected: index == 12,
                    menus: [
                      buildMenuWithPermission(
                        'gestion autorisations',
                        Menu(
                          title: 'Autorisations',
                          press: () {
                            setState(() {
                              index = 12;
                            });
                            widget.switchView(RoleAndPermission());
                          },
                          isSelected: index == 12,
                          icon: Icon(
                            Icons.security,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FootMenu(),
          ),
        ],
      ),
    );
  }
}
