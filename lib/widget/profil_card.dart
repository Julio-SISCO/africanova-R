import 'package:africanova/database/user.dart';
import 'package:africanova/provider/auth_provider.dart';

import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/widget/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class ProfilCard extends StatefulWidget {
  const ProfilCard({super.key});

  @override
  State<ProfilCard> createState() => _ProfilCardState();
}

class _ProfilCardState extends State<ProfilCard> {
  late String username = 'Inconnu';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    var box = Hive.box<User>('userBox');
    setState(() {
      username = box.get('currentUser')?.username ?? 'Inconnu';
    });
  }

  Future<void> clearAllHiveBoxes() async {}

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      padding: EdgeInsets.all(4.0),
      itemBuilder: (BuildContext context) {
        return const <PopupMenuEntry>[
          PopupMenuItem(
            value: 'compte',
            child: Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 8),
                Text('Mon compte'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'parametres',
            child: Row(
              children: [
                Icon(Icons.settings),
                SizedBox(width: 8),
                Text('Paramètres'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'deconnexion',
            child: Row(
              children: [
                Icon(Icons.exit_to_app),
                SizedBox(width: 8),
                Text('Se déconnecter'),
              ],
            ),
          ),
        ];
      },
      icon: Row(
        children: [
          CircleAvatar(
            backgroundColor: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .primary,
            radius: 16.0,
            child: Icon(
              Icons.person,
              color: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .tertiary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0 / 3),
            child: Text(
              username.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .tertiary,
          ),
        ],
      ),
      onSelected: (value) {
        if (value == 'compte') {
          // Action
        } else if (value == 'parametres') {
          // Action
        } else if (value == 'deconnexion') {
          showCancelConfirmationDialog(
            context,
            () {
              globalLogout();
            },
            'Vous êtes sur le point de vous déconnecter.',
          );
        }
      },
    );
  }
}
