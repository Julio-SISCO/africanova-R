// ignore_for_file: deprecated_member_use

import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/services/service_content.dart';
import 'package:africanova/view/components/services/service_outils.dart';
import 'package:africanova/view/components/services/service_saver.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServiceHead extends StatefulWidget {
  final Function(Widget) switchView;
  final Function(Widget) changeContent;
  final Function(bool) updateLoading;
  const ServiceHead({
    super.key,
    required this.changeContent,
    required this.updateLoading,
    required this.switchView,
  });

  @override
  State<ServiceHead> createState() => _ServiceHeadState();
}

class _ServiceHeadState extends State<ServiceHead> {
  int _activeIndex = 0;
  ButtonStyle _buttonStyle({bool isActive = false}) {
    return TextButton.styleFrom(
      elevation: 0.0,
      backgroundColor: isActive
          ? Provider.of<ThemeProvider>(context)
              .themeData
              .colorScheme
              .primary
              .withOpacity(0.3)
          : Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
      foregroundColor:
          Provider.of<ThemeProvider>(context).themeData.colorScheme.tertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
    );
  }

  void _onButtonPressed(int index, Widget content) {
    setState(() {
      _activeIndex = index;
    });
    widget.changeContent(content);
  }

  @override
  Widget build(BuildContext context) {
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
              message: "Retour à l'accueil",
              child: TextButton.icon(
                onPressed: () => _onButtonPressed(
                    0,
                    ServiceContent(
                      switchView: (Widget w) => widget.switchView(w),
                    )),
                style: _buttonStyle(isActive: _activeIndex == 0),
                icon: Icon(
                  Icons.home_filled,
                  color: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .tertiary,
                ),
                label: const Text(
                  "Accueil",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            buildMenuWithPermission(
              'voir outils',
              Tooltip(
                message: "Afficher les outils disponibles",
                child: TextButton.icon(
                  onPressed: () => _onButtonPressed(1, const ServiceOutil()),
                  style: _buttonStyle(isActive: _activeIndex == 1),
                  icon: Icon(
                    Icons.build_circle,
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .tertiary,
                  ),
                  label: const Text(
                    "Outils",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            buildMenuWithPermission(
              'enregistrer services',
              Tooltip(
                message: "Ajouter un nouveau service",
                child: TextButton.icon(
                  onPressed: () => _onButtonPressed(
                    3,
                    ServiceSaver(),
                  ),
                  style: TextButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .secondary,
                    foregroundColor: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .tertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Enregistrer",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
