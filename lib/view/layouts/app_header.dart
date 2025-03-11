import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/widget/notif_alert.dart';
import 'package:africanova/widget/profil_card.dart';
import 'package:africanova/widget/search_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppHeader extends StatefulWidget {
  final Function(Widget) switchView;
  final VoidCallback hideSideBar;
  const AppHeader({
    super.key,
    required this.switchView,
    required this.hideSideBar,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: Provider.of<ThemeProvider>(context).themeData.colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Wrap(
            children: [
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: widget.hideSideBar,
                color: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .tertiary,
              ),
              const SearchField(),
            ],
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const AlertNotif(),
              SizedBox(width: 20),
              const ProfilCard(),
            ],
          ),
        ],
      ),
    );
  }
}
