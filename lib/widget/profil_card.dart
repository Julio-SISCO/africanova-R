import 'package:africanova/database/user.dart';
import 'package:africanova/provider/auth_provider.dart';

import 'package:africanova/theme/theme_provider.dart';
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
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 50,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Déconnexion',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Voulez-vous vraiment vous déconnecter ?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Annuler'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                              onPressed: () async {
                                globalLogout();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
