import 'package:africanova/database/client.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:flutter/material.dart';
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
    filteredClients = Hive.box<Client>('clientBox').values.toList();
  }

  void _filter(String query, List<Client> all) {
    final search = query.toLowerCase();
    setState(() {
      filteredClients = query.isEmpty
          ? all
          : all
              .where((c) => (c.fullname ?? '').toLowerCase().contains(search))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final color =
        Provider.of<ThemeProvider>(context).themeData.colorScheme.primary;

    return ValueListenableBuilder<Box<Client>>(
      valueListenable: Hive.box<Client>('clientBox').listenable(),
      builder: (_, box, __) {
        final clients = box.values.toList();

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          elevation: 0,
          color: color,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  onChanged: (val) => _filter(val, clients),
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              if (clients.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Aucun client disponible',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              else if (filteredClients.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Aucun résultat trouvé',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView.builder(
                      itemCount: filteredClients.length,
                      itemBuilder: (_, i) {
                        final client = filteredClients[i];
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: _buildClientTile(client),
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

  Widget _buildClientTile(Client client) {
    return ListTile(
      title: Text(
        client.fullname ?? 'Client inconnu',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${client.adresse ?? 'Adresse'} | ${client.contact ?? 'Contact'}',
        style: const TextStyle(
          color: Colors.blueGrey,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          fontSize: 14,
        ),
      ),
      onTap: () => widget.chooseClient(client),
    );
  }
}
