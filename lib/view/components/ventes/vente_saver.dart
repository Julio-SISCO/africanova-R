import 'package:africanova/controller/vente_controller.dart';
import 'package:africanova/database/vente.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/view/components/ventes/article_selection.dart';
import 'package:africanova/database/client.dart';
import 'package:africanova/database/ligne_vente.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/ventes/client_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class VenteSaver extends StatefulWidget {
  final Vente? editableVente;
  const VenteSaver({super.key, this.editableVente});

  @override
  State<VenteSaver> createState() => _VenteSaverState();
}

class _VenteSaverState extends State<VenteSaver> {
  Client? client;

  bool _showTaxe = false;
  bool _isLoading = false;
  bool _showRemise = false;
  bool _taxeInPercent = false;
  bool _remiseInPercent = false;

  double _total = 0.0;
  double _totalLignes = 0.0;

  List<LigneVente> lignes = [];

  final TextEditingController _taxeController = TextEditingController();
  final TextEditingController _remiseController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _designRemiseController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  String clientErrorMessage = "";
  String totalErrorMessage = "";
  String lignesErrorMessage = "";
  Widget _option = Container();

  @override
  void initState() {
    super.initState();
    _option = ArticleSelection(updateSelection: (LigneVente l) {
      updateSelection(l);
    });
    _taxeController.text = "0";
    _remiseController.text = "0";
    _valueController.text = "0";
    _initData();
  }

  void _initData() {
    if (widget.editableVente != null) {
      final vente = widget.editableVente;
      setState(() {
        client = vente?.client;
        lignes = vente?.lignes ?? [];
        _total = vente?.montantTotal ?? 0.0;
        _taxeController.text = vente?.taxe?.toStringAsFixed(0) ?? "0";
        _remiseController.text = vente?.remise?.toStringAsFixed(0) ?? "0";
        _designationController.text = vente?.designationTaxe ?? "";
        _designRemiseController.text = vente?.designationRemise ?? "";
        _taxeInPercent = vente?.taxeInPercent ?? false;
        _remiseInPercent = vente?.remiseInPercent ?? false;

        if (vente != null && vente.remise != null && vente.remise! > 0) {
          _showRemise = true;
        }
        if (vente != null && vente.taxe != null && vente.taxe! > 0) {
          _showTaxe = true;
        }
      });
    }
  }

  void updateSelection(LigneVente l) {
    setState(() {
      final index = lignes.indexWhere(
          (ligne) => (ligne.article?.id ?? 0) == (l.article?.id ?? 0));
      if (index != -1) {
        lignes[index].quantite += 1;
      } else {
        lignes.add(l);
      }
      lignesErrorMessage = "";
    });
    _calculateTotal();
  }

  void _editQuantity(LigneVente ligne, double value) {
    int index = lignes
        .indexWhere((l) => (l.article?.id ?? 0) == (ligne.article?.id ?? 0));
    if (index != -1) {
      setState(() {
        lignes[index].quantite = value.toInt();
      });
      _calculateTotal();
    }
  }

  void removeSelection(LigneVente l) {
    setState(() {
      final index = lignes.indexWhere(
          (ligne) => (ligne.article?.id ?? 0) == (l.article?.id ?? 0));
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
        _totalLignes += (ligne.article?.prixVente ?? 0) * ligne.quantite;
      }
    });
    double taxe = 0.0;
    double remise = 0.0;
    if (_taxeInPercent) {
      taxe += _totalLignes * double.parse(_taxeController.text) / 100;
    } else {
      taxe += double.parse(_taxeController.text);
    }
    if (_remiseInPercent) {
      remise -= _totalLignes * double.parse(_remiseController.text) / 100;
    } else {
      remise -= double.parse(_remiseController.text);
    }
    setState(() {
      _total = _totalLignes + taxe + remise;
      if (_total >= 0) {
        totalErrorMessage = "";
      } else {
        totalErrorMessage = "Veuillez bien vérifier vos Remises et Taxes.";
      }
    });
  }

  void chooseClient(Client client) {
    setState(() {
      this.client = client;
      clientErrorMessage = "";
    });
  }

  Future<void> showNumericInputDialog(
    BuildContext context,
    String libelle,
    LigneVente ligne,
    Function(LigneVente ligne, double value) updateValue,
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

  Future<void> _enregistrer(String status) async {
    if (client != null && lignes.isNotEmpty && _total >= 0) {
      setState(() {
        _isLoading = true;
      });
      double montantTotal = _total;

      final Vente vente = Vente(
        montantTotal: montantTotal,
        lignes: lignes,
        client: client,
        designationTaxe: _designationController.text,
        designationRemise: _designRemiseController.text,
        taxe: double.parse(_taxeController.text),
        remise: double.parse(_remiseController.text),
        remiseInPercent: _remiseInPercent,
        taxeInPercent: _taxeInPercent,
        status: status,
      );

      final result = await sendVente(vente);
      if (result['status']) {
        setState(() {
          lignes.clear();
          client = null;
          _taxeController.text = "0";
          _remiseController.text = "0";
          _designationController.text = "";
          _designRemiseController.text = "";
          _valueController.text = "0";
          _showTaxe = false;
          _showRemise = false;
          _taxeInPercent = false;
          _remiseInPercent = false;
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
      if (client == null) {
        setState(() {
          clientErrorMessage = "Veuillez sélectionner un client.";
        });
      }
      if (lignes.isEmpty) {
        setState(() {
          lignesErrorMessage = "Veuillez ajouter des articles à la vente.";
        });
      }
      if (_total < 0) {
        setState(() {
          totalErrorMessage = "Veuillez bien vérifier vos Remises et Taxes.";
        });
      }
    }
  }

  Future<void> _modifier(String status) async {
    if (client != null && lignes.isNotEmpty && _total >= 0) {
      setState(() {
        _isLoading = true;
      });
      double montantTotal = _total;

      final Vente vente = Vente(
        id: widget.editableVente?.id ?? 0,
        montantTotal: montantTotal,
        lignes: lignes,
        client: client,
        designationTaxe: _designationController.text,
        designationRemise: _designRemiseController.text,
        taxe: double.parse(_taxeController.text),
        remise: double.parse(_remiseController.text),
        remiseInPercent: _remiseInPercent,
        taxeInPercent: _taxeInPercent,
        status: status,
      );

      final result = await updateVente(vente, widget.editableVente?.id ?? 0);
      if (result['status']) {
        setState(() {
          lignes.clear();
          client = null;
          _taxeController.text = "0";
          _remiseController.text = "0";
          _designationController.text = "";
          _designRemiseController.text = "";
          _valueController.text = "0";
          _showTaxe = false;
          _showRemise = false;
          _taxeInPercent = false;
          _remiseInPercent = false;
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
      if (client == null) {
        setState(() {
          clientErrorMessage = "Veuillez sélectionner un client.";
        });
      }
      if (lignes.isEmpty) {
        setState(() {
          lignesErrorMessage = "Veuillez ajouter des articles à la vente.";
        });
      }
      if (_total < 0) {
        setState(() {
          totalErrorMessage = "Veuillez bien vérifier vos Remises et Taxes.";
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
            padding: EdgeInsets.all(4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 4,
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
                      padding: EdgeInsets.all(4.0),
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
                                child: clientSelect(),
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
                                child: taxesRemise(),
                              ),
                            ),
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
                  'Articles Utilisés',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_totalLignes.toStringAsFixed(0)} f',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            if (lignesErrorMessage != "")
              Align(
                alignment: Alignment.center,
                child: Text(
                  lignesErrorMessage,
                  style: TextStyle(
                    color: Colors.red[800],
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
                        updateSelection: (LigneVente l) => updateSelection(l),
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

  Widget clientSelect() {
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
                    'Client',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  if (clientErrorMessage != "")
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        clientErrorMessage,
                        style: TextStyle(
                          color: Colors.red[800],
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (client != null)
                    ListTile(
                      title: Text(
                        client!.fullname!.toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(
                        '${client!.adresse ?? 'Adresse'} | ${client!.contact ?? 'Contact'}',
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
              ClientSelection(
                chooseClient: (Client c) => chooseClient(c),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Appliquer une taxe',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Checkbox(
                          
                            activeColor: Provider.of<ThemeProvider>(context)
                                .themeData
                                .colorScheme
                                .secondary,
                          value: _showTaxe,
                          onChanged: (bool? value) {
                            setState(() {
                              _showTaxe = value ?? false;
                              _taxeInPercent = false;
                            });
                            _taxeController.text = '0';
                            _calculateTotal();
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Appliquer une remise',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Checkbox(
                          
                            activeColor: Provider.of<ThemeProvider>(context)
                                .themeData
                                .colorScheme
                                .secondary,
                          value: _showRemise,
                          onChanged: (bool? value) {
                            setState(() {
                              _showRemise = value ?? false;
                              _remiseInPercent = false;
                            });
                            _remiseController.text = '0';
                            _calculateTotal();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                if (_showTaxe)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _taxeController,
                          cursorColor: Provider.of<ThemeProvider>(context)
                              .themeData
                              .colorScheme
                              .tertiary,
                          decoration: InputDecoration(
                            labelText: "Taxe",
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            labelStyle: TextStyle(
                              color: Provider.of<ThemeProvider>(context)
                                  .themeData
                                  .colorScheme
                                  .tertiary,
                            ),
                          ),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d*')),
                          ],
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() {
                                _taxeController.text = '0';
                              });
                            }
                            _calculateTotal();
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Checkbox(
                            
                            activeColor: Provider.of<ThemeProvider>(context)
                                .themeData
                                .colorScheme
                                .secondary,
                            value: _taxeInPercent,
                            onChanged: (bool? value) {
                              setState(() {
                                _taxeInPercent = value ?? false;
                              });
                              _calculateTotal();
                            },
                          ),
                          Text(
                            "(%)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextFormField(
                          controller: _designationController,
                          cursorColor: Provider.of<ThemeProvider>(context)
                              .themeData
                              .colorScheme
                              .tertiary,
                          decoration: InputDecoration(
                            labelText: "Désignation (Optionnelle)",
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            labelStyle: TextStyle(
                              color: Provider.of<ThemeProvider>(context)
                                  .themeData
                                  .colorScheme
                                  .tertiary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16.0),
                if (_showRemise)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _remiseController,
                          cursorColor: Provider.of<ThemeProvider>(context)
                              .themeData
                              .colorScheme
                              .tertiary,
                          decoration: InputDecoration(
                            labelText: "Remise",
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            labelStyle: TextStyle(
                              color: Provider.of<ThemeProvider>(context)
                                  .themeData
                                  .colorScheme
                                  .tertiary,
                            ),
                          ),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d*')),
                          ],
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() {
                                _remiseController.text = '0';
                              });
                            }
                            _calculateTotal();
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Checkbox(
                            
                            activeColor: Provider.of<ThemeProvider>(context)
                                .themeData
                                .colorScheme
                                .secondary,
                            value: _remiseInPercent,
                            onChanged: (bool? value) {
                              setState(() {
                                _remiseInPercent = value ?? false;
                              });
                              _calculateTotal();
                            },
                          ),
                          Text(
                            "(%)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextFormField(
                          controller: _designRemiseController,
                          cursorColor: Provider.of<ThemeProvider>(context)
                              .themeData
                              .colorScheme
                              .tertiary,
                          decoration: InputDecoration(
                            labelText: "Désignation (Optionnelle)",
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            labelStyle: TextStyle(
                              color: Provider.of<ThemeProvider>(context)
                                  .themeData
                                  .colorScheme
                                  .tertiary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                'Total de ${_total.toStringAsFixed(0)} f',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                totalErrorMessage,
                style: TextStyle(
                  color: Colors.red[800],
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 34.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                    Icons.mobile_friendly_rounded, 'Conclure', false, () {
                  widget.editableVente != null
                      ? _modifier('complete')
                      : _enregistrer('complete');
                }),
                const SizedBox(width: 16.0),
                _buildActionButton(Icons.save, 'Sauvegarder', false, () {
                  widget.editableVente != null
                      ? _modifier('en_attente')
                      : _enregistrer('en_attente');
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

  Widget _ligneCard(LigneVente ligne) {
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
                    width: totalWidth * 0.4,
                    child: Text(
                      ligne.article?.libelle ?? 'unknown',
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
                          "${ligne.quantite} x ${formatMontant(ligne.article?.prixVente ?? 0)} f",
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: totalWidth * .2,
                    child: Text(
                      formatMontant(
                          (ligne.article?.prixVente ?? 0) * ligne.quantite),
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
