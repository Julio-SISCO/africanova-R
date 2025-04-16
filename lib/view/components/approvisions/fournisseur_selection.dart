import 'package:africanova/database/fournisseur.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class FournisseurSelection extends StatefulWidget {
  final Function(Fournisseur) chooseFournisseur;
  const FournisseurSelection({super.key, required this.chooseFournisseur});

  @override
  State<FournisseurSelection> createState() => _FournisseurSelectionState();
}

class _FournisseurSelectionState extends State<FournisseurSelection> {
  List<Fournisseur> filteredFournisseurs = [];

  @override
  void initState() {
    super.initState();
    final fournisseurs = Hive.box<Fournisseur>('fournisseurBox').values.toList();
    filteredFournisseurs = fournisseurs;
  }

  void filterFournisseurs(String query, List<Fournisseur> fournisseurs) {
    setState(() {
      filteredFournisseurs = query.isEmpty
          ? fournisseurs
          : fournisseurs.where((fournisseur) {
              final labelLower = fournisseur.fullname?.toLowerCase() ?? '';
              final searchLower = query.toLowerCase();
              return labelLower.contains(searchLower);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Fournisseur>>(
      valueListenable: Hive.box<Fournisseur>('fournisseurBox').listenable(),
      builder: (context, box, _) {
        final List<Fournisseur> fournisseurs = box.values.toList();

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
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
                    filterFournisseurs(value, fournisseurs);
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
              if (fournisseurs.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Aucun fournisseur disponible',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredFournisseurs.length,
                      itemBuilder: (context, index) {
                        final fournisseur = filteredFournisseurs[index];
                        return ListTile(
                          title: Text(
                            fournisseur.fullname ?? 'Fournisseur inconnu',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${fournisseur.adresse ?? 'Adresse'} | ${fournisseur.contact ?? 'Contact'}',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                          ),
                          onTap: () {
                            widget.chooseFournisseur(fournisseur);
                            setState(() {
                              // _fournisseur = fournisseur;
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
