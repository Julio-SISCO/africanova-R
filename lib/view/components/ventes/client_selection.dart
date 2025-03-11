// ignore_for_file: unnecessary_import, deprecated_member_use

import 'package:africanova/database/client.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class ClientSelection extends StatefulWidget {
  final Function(Client) chooseClient;
  const ClientSelection({super.key, required this.chooseClient});

  @override
  State<ClientSelection> createState() => _ClientSelectionState();
}

class _ClientSelectionState extends State<ClientSelection> {
  List<Client> filteredClients = [];

  @override
  void initState() {
    super.initState();
    final clients = Hive.box<Client>('clientBox').values.toList();
    filteredClients = clients;
  }

  void filterClients(String query, List<Client> clients) {
    setState(() {
      filteredClients = query.isEmpty
          ? clients
          : clients.where((client) {
              final labelLower = client.fullname?.toLowerCase() ?? '';
              final searchLower = query.toLowerCase();
              return labelLower.contains(searchLower);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Client>>(
      valueListenable: Hive.box<Client>('clientBox').listenable(),
      builder: (context, box, _) {
        final List<Client> clients = box.values.toList();

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          elevation: 0.0,
          color:
              Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    filterClients(value, clients);
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              if (clients.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Aucun client disponible',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredClients.length,
                      itemBuilder: (context, index) {
                        final client = filteredClients[index];
                        return ListTile(
                          title: Text(
                            client.fullname ?? 'Client inconnu',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${client.adresse ?? 'Adresse'} | ${client.contact ?? 'Contact'}',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                          ),
                          onTap: () {
                            widget.chooseClient(client);
                            setState(() {
                              // _client = client;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
