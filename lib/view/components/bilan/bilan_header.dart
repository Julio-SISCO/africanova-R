import 'package:africanova/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BilanHeader extends StatefulWidget {
  final Function(Widget) changeContent;
  final Function(bool) updateLoading;
  const BilanHeader({
    super.key,
    required this.changeContent,
    required this.updateLoading,
  });

  @override
  State<BilanHeader> createState() => _BilanHeaderState();
}

class _BilanHeaderState extends State<BilanHeader> {
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

  void onButtonPressed(int index, Widget content) {
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
              message: "Bilan des stocks d'articles",
              child: TextButton.icon(
                onPressed: () {},
                style: _buttonStyle(isActive: _activeIndex == 0),
                icon: Icon(
                  Icons.calculate_outlined,
                  color: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .tertiary,
                ),
                label: const Text(
                  "Stock",
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
            Tooltip(
              message: "Bilan des ventes",
              child: TextButton.icon(
                onPressed: () {},
                style: _buttonStyle(isActive: _activeIndex == 2),
                icon: Icon(
                  Icons.sell,
                  color: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .tertiary,
                ),
                label: const Text(
                  "Ventes",
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
            Tooltip(
              message: "Bilan des services",
              child: TextButton.icon(
                onPressed: () {},
                style: _buttonStyle(isActive: _activeIndex == 3),
                icon: Icon(
                  Icons.computer,
                  color: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .tertiary,
                ),
                label: const Text(
                  "Services",
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
            Tooltip(
              message: "Autres type de bilan",
              child: TextButton.icon(
                onPressed: () {},
                style: _buttonStyle(isActive: _activeIndex == 1),
                icon: Icon(
                  Icons.onetwothree_rounded,
                  color: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .tertiary,
                ),
                label: const Text(
                  "Autres",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
