import 'package:africanova/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HeadMenu extends StatelessWidget {
  const HeadMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0 * 1.5,
      ),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color:
            Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      height: 150,
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          height: 60,
        ),
      ),
    );
  }
}

class MenuDrop extends StatefulWidget {
  final String title;
  final Icon icon;
  final bool isSelected;
  final List<Widget> menus;
  const MenuDrop({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.menus,
  });

  @override
  State<MenuDrop> createState() => _MenuDropState();
}

class _MenuDropState extends State<MenuDrop> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      iconColor:
          Provider.of<ThemeProvider>(context).themeData.colorScheme.tertiary,
      collapsedIconColor:
          Provider.of<ThemeProvider>(context).themeData.colorScheme.tertiary,
      leading: widget.icon,
      shape: Border.all(style: BorderStyle.none),
      initiallyExpanded: widget.isSelected,
      tilePadding: EdgeInsets.symmetric(horizontal: 8.0),
      childrenPadding: EdgeInsets.symmetric(horizontal: .0),
      title: Text(
        widget.title,
        style: TextStyle(
          color: widget.isSelected
              ? Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .secondary
              : Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .tertiary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      children: [
        for (Widget menu in widget.menus)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: menu,
          ),
      ],
    );
  }
}

class Menu extends StatelessWidget {
  final String title;
  final Icon? icon;
  final VoidCallback press;
  final bool isSelected;

  const Menu({
    super.key,
    required this.title,
    this.icon,
    required this.press,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selectedColor: isSelected
          ? Provider.of<ThemeProvider>(context).themeData.colorScheme.secondary
          : Provider.of<ThemeProvider>(context).themeData.colorScheme.tertiary,
      onTap: press,
      selected: isSelected,
      horizontalTitleGap: 0.0,
      contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
      leading: icon,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected
                ? Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .secondary
                : null,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class FootMenu extends StatefulWidget {
  const FootMenu({super.key});

  @override
  State<FootMenu> createState() => _FootMenuState();
}

class _FootMenuState extends State<FootMenu> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Divider(
            color: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .primary,
          ),
          TextButton.icon(
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            label: Text(
              Provider.of<ThemeProvider>(context).isLightTheme()
                  ? "mode nuit"
                  : "mode jour",
              style: TextStyle(
                color: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .tertiary,
              ),
            ),
            iconAlignment: Provider.of<ThemeProvider>(context).isLightTheme()
                ? IconAlignment.end
                : IconAlignment.start,
            icon: Icon(
              Provider.of<ThemeProvider>(context).isLightTheme()
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .tertiary,
            ),
          ),
          Divider(
            color: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .primary,
          ),
          Center(
            child: Text(
              'Africa Nova Group\nVersion 1.1.3',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
