import 'package:africanova/controller/approvision_controller.dart';
import 'package:africanova/database/approvision.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/view/components/approvisions/article_selection.dart';
import 'package:africanova/view/components/approvisions/fournisseur_selection.dart';
import 'package:africanova/database/fournisseur.dart';
import 'package:africanova/database/ligne_approvision.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ApprovisionSaver extends StatefulWidget {
  final Approvision? editableApprovision;
  const ApprovisionSaver({super.key, this.editableApprovision});

  @override
  State<ApprovisionSaver> createState() => _ApprovisionSaverState();
}

class _ApprovisionSaverState extends State<ApprovisionSaver> {
  Fournisseur? fournisseur;

  bool _isLoading = false;

  double _total = 0.0;
  double _totalLignes = 0.0;

  List<LigneApprovision> lignes = [];

  final TextEditingController _valueController = TextEditingController();

  String fournisseurErrorMessage = "";
  Widget _option = Container();

  @override
  void initState() {
    super.initState();
    _option = ArticleSelection(
        count: 3,
        updateSelection: (LigneApprovision l) {
          updateSelection(l);
        });
    _valueController.text = "0";
    _initData();
  }

  void _initData() {
    if (widget.editableApprovision != null) {
      final approvision = widget.editableApprovision;
      setState(() {
        fournisseur = approvision?.fournisseur;
        lignes = approvision?.lignes ?? [];
        _total = approvision?.montantTotal ?? 0.0;
      });
    }
  }

  void updateSelection(LigneApprovision l) {
    setState(() {
      final index =
          lignes.indexWhere((ligne) => ligne.article.id == l.article.id);
      if (index != -1) {
        lignes[index].quantite += 1;
      } else {
        lignes.add(l);
      }
    });
    _calculateTotal();
  }

  void _editQuantity(LigneApprovision ligne, double value) {
    int index = lignes.indexWhere((l) => l.article.id == ligne.article.id);
    if (index != -1) {
      setState(() {
        lignes[index].quantite = value.toInt();
      });
      _calculateTotal();
    }
  }

  void _editPrixAchat(LigneApprovision ligne, double value) {
    int index = lignes.indexWhere((l) => l.article.id == ligne.article.id);
    if (index != -1) {
      setState(() {
        lignes[index].prix = value;
      });
      _calculateTotal();
    }
  }

  void removeSelection(LigneApprovision l) {
    setState(() {
      final index =
          lignes.indexWhere((ligne) => ligne.article.id == l.article.id);
      if (index != -1) {
        lignes.removeAt(index);
      }
    });
    _calculateTotal();
  }

  void changeOption(Widget option) {
    setState(() {
      _option = option;
    });
  }

  void _calculateTotal() {
    _total = 0.0;
    _totalLignes = 0.0;
    setState(() {
      for (var ligne in lignes) {
        _totalLignes += (ligne.prix ?? 0) * ligne.quantite;
      }
    });
    setState(() {
      _total = _totalLignes;
    });
  }

  void chooseFournisseur(Fournisseur fournisseur) {
    setState(() {
      this.fournisseur = fournisseur;
      fournisseurErrorMessage = "";
    });
  }

  Future<void> showNumericInputDialog(
    BuildContext context,
    String libelle,
    LigneApprovision ligne,
    Function(LigneApprovision ligne, double value) updateValue,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(libelle),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  autofocus: true,
                  controller: _valueController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Entrez une valeur',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une valeur.';
                    }
                    final doubleValue = double.tryParse(value);
                    if (doubleValue == null || doubleValue <= 0) {
                      return 'Veuillez entrer une valeur correcte.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                final newTarif = double.parse(_valueController.text);
                Navigator.of(dialogContext).pop();
                updateValue(ligne, newTarif);
                _valueController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _enregistrer() async {
    if (fournisseur != null && lignes.isNotEmpty && _total >= 0) {
      setState(() {
        _isLoading = true;
      });
      double montantTotal = _total;

      final Approvision approvision = Approvision(
        montantTotal: montantTotal,
        lignes: lignes,
        fournisseur: fournisseur,
      );

      final result = await saveApprovision(approvision);
      if (result['status']) {
        setState(() {
          lignes.clear();
          fournisseur = null;
          _valueController.text = "0";
          _calculateTotal();
        });
      }
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        '',
        result["message"],
        titleText: SizedBox.shrink(),
        messageText: Center(
          child: Text(result["message"]),
        ),
        maxWidth: 300,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      if (fournisseur == null) {
        setState(() {
          fournisseurErrorMessage = "Veuillez sélectionner un fournisseur.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          margin: EdgeInsets.all(.0),
          elevation: 0.0,
          color:
              Provider.of<ThemeProvider>(context).themeData.colorScheme.surface,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical:  4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 6,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    elevation: 0.0,
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .primary,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 
                       4.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              elevation: 0.0,
                              color: Provider.of<ThemeProvider>(context)
                                  .themeData
                                  .colorScheme
                                  .surface,
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                                child: fournisseurSelect(),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              elevation: 0.0,
                              color: Provider.of<ThemeProvider>(context)
                                  .themeData
                                  .colorScheme
                                  .surface,
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                                child: articleSelected(),
                              ),
                            ),
                            // Card(
                            //   shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(4.0),
                            //   ),
                            //   elevation: 0.0,
                            //   color: Provider.of<ThemeProvider>(context)
                            //       .themeData
                            //       .colorScheme
                            //       .surface,
                            //   child: Padding(
                            //     padding: EdgeInsets.all(4.0),
                            //     child: taxesRemise(),
                            //   ),
                            // ),
                            summary(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _option,
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.transparent,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Container(
                color: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .tertiary
                    .withOpacity(0.3),
                width: 80,
                height: 80,
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  color: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .secondary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget articleSelected() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      elevation: 0.0,
      color: Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Articles',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${formatMontant(_totalLignes)} f',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...List.generate(
                  lignes.length,
                  (index) {
                    final ligne = lignes[index];
                    return _ligneCard(ligne);
                  },
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _option = ArticleSelection(
                        count: 3,
                        updateSelection: (LigneApprovision l) =>
                            updateSelection(l),
                      );
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    margin: EdgeInsets.only(
                        top: .0, left: 4.0, right: 4.0, bottom: 4.0),
                    color: Colors.blueGrey.withOpacity(0.1),
                    child: Center(
                      child: Icon(Icons.add_circle_outline),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget fournisseurSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          elevation: 0.0,
          margin: EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0, bottom: 1.0),
          color:
              Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Fournisseur',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  if (fournisseurErrorMessage != "")
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        fournisseurErrorMessage,
                        style: TextStyle(
                          color: Colors.red[800],
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (fournisseur != null)
                    ListTile(
                      title: Text(
                        fournisseur!.fullname!.toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(
                        '${fournisseur!.adresse ?? 'Adresse'} | ${fournisseur!.contact ?? 'Contact'}',
                        style: TextStyle(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 14),
                      ),
                    ),
                ],
              )),
        ),
        InkWell(
          onTap: () {
            changeOption(
              FournisseurSelection(
                chooseFournisseur: (Fournisseur c) => chooseFournisseur(c),
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 50.0,
            margin:
                EdgeInsets.only(top: .0, left: 4.0, right: 4.0, bottom: 4.0),
            color: Colors.blueGrey.withOpacity(0.1),
            child: Center(
              child: Icon(Icons.add_circle_outline),
            ),
          ),
        ),
      ],
    );
  }

  Widget taxesRemise() {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          elevation: 0.0,
          color:
              Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Autres tarifs',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget summary() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      elevation: 0.0,
      color: Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total de ${formatMontant(_total)} f',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 34.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 16.0),
                _buildActionButton(Icons.save, 'Sauvegarder', false, () {
                  widget.editableApprovision != null ? () {} : _enregistrer();
                }),
                const SizedBox(width: 16.0),
                _buildActionButton(Icons.print, 'Imprimer', false, () {
                  // printFacture(_fournisseur, context);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, bool disabled, VoidCallback onPress) {
    return SizedBox(
      height: 38,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          elevation: 4.0,
          backgroundColor:
              Provider.of<ThemeProvider>(context).themeData.colorScheme.surface,
          foregroundColor: Provider.of<ThemeProvider>(context)
              .themeData
              .colorScheme
              .tertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        onPressed: disabled ? null : onPress,
        icon: Icon(
          icon,
          color: Provider.of<ThemeProvider>(context)
              .themeData
              .colorScheme
              .tertiary,
        ),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _ligneCard(LigneApprovision ligne) {
    return LayoutBuilder(builder: (context, constraints) {
      double totalWidth = constraints.maxWidth;
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        elevation: 0.0,
        margin: EdgeInsets.all(0.0),
        color:
            Provider.of<ThemeProvider>(context).themeData.colorScheme.surface,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: totalWidth * 0.38,
                    child: Text(
                      "${ligne.article.libelle}",
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: totalWidth * 0.3,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      runSpacing: 0.0,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit_square,
                            size: 18.0,
                          ),
                          onPressed: () {
                            showNumericInputDialog(
                              context,
                              'Quantité',
                              ligne,
                              _editQuantity,
                            );
                          },
                        ),
                        Text(
                          "${ligne.quantite} x ${formatMontant(ligne.prix ?? 0)} f",
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit_square,
                            size: 18.0,
                          ),
                          onPressed: () {
                            showNumericInputDialog(
                              context,
                              'Prix d\'achat',
                              ligne,
                              _editPrixAchat,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: totalWidth * .2,
                    child: Text(
                      formatMontant((ligne.prix ?? 0) * ligne.quantite),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 20.0,
                    ),
                    onPressed: () => removeSelection(ligne),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
