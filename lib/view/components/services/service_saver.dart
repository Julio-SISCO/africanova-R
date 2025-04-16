import 'package:africanova/controller/service_controller.dart';
import 'package:africanova/database/type_article.dart';
import 'package:africanova/database/employer.dart';
import 'package:africanova/database/ligne_article.dart';
import 'package:africanova/database/ligne_outil.dart';
import 'package:africanova/database/type_outil.dart';
import 'package:africanova/database/service.dart';
import 'package:africanova/database/client.dart';
import 'package:africanova/database/type_service.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/view/components/services/service_tool_selection.dart';
import 'package:africanova/view/components/ventes/client_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ServiceSaver extends StatefulWidget {
  final Service? editableService;
  const ServiceSaver({super.key, this.editableService});

  @override
  State<ServiceSaver> createState() => _ServiceSaverState();
}

class _ServiceSaverState extends State<ServiceSaver> {
  Client? client;

  bool _showTaxe = false;
  bool _isLoading = false;
  bool _showOtherAmount = false;
  bool _showRemise = false;
  bool _taxeInPercent = false;
  bool _remiseInPercent = false;
  bool expanded = false;

  double _totalLignesArticles = 0.0;
  double _total = 0.0;
  double _totalLignesOutils = 0.0;

  List<LigneArticle> lignesArticles = [];
  List<LigneOutil> lignesOutils = [];
  List<TypeService> typesServices = [];

  final TextEditingController _taxeController = TextEditingController();
  final TextEditingController _remiseController = TextEditingController();
  final TextEditingController _designationTaxeController =
      TextEditingController();
  final TextEditingController _designationRemiseController =
      TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();

  String clientErrorMessage = "";
  String totalErrorMessage = "";
  Widget _option = Container();

  @override
  void initState() {
    super.initState();
    _option = ClientSelection(chooseClient: chooseClient);
    _taxeController.text = "0";
    _remiseController.text = "0";
    _valueController.text = "0";
    _montantController.text = '0';
    _initData();
  }

  void _initData() {
    if (widget.editableService != null) {
      final service = widget.editableService;
      setState(() {
        expanded = true;
        client = service?.client;
        lignesArticles = service?.articles ?? [];
        lignesOutils = service?.outils ?? [];
        typesServices = service?.typeServices ?? [];
        _total = service?.total ?? 0.0;
        _taxeController.text = service?.taxe?.toStringAsFixed(0) ?? "0";
        _remiseController.text = service?.remise?.toStringAsFixed(0) ?? "0";
        _designationTaxeController.text = service?.designationTaxe ?? "";
        _designationRemiseController.text = service?.designationRemise ?? "";
        _taxeInPercent = service?.taxeInPercent ?? false;
        _remiseInPercent = service?.remiseInPercent ?? false;

        if (service != null && service.remise != null && service.remise! > 0) {
          _showRemise = true;
        }
        if (service != null && service.taxe != null && service.taxe! > 0) {
          _showTaxe = true;
        }
      });
    }
  }

  void _toggleTarif(LigneOutil ligne) {
    int index = lignesOutils.indexWhere((l) => l.id == ligne.id);
    if (index != -1) {
      setState(() {
        lignesOutils[index].applyTarif =
            !(lignesOutils[index].applyTarif ?? false);
      });
      _calculateTotal();
    }
  }

  void _editTarif(LigneOutil ligne, double value) {
    int index = lignesOutils.indexWhere((l) => l.id == ligne.id);
    if (index != -1) {
      setState(() {
        lignesOutils[index].montant = value;
      });
      _calculateTotal();
    }
  }

  void _editQte(LigneOutil ligne, double value) {
    int index = lignesOutils.indexWhere((l) => l.id == ligne.id);
    if (index != -1) {
      setState(() {
        lignesOutils[index].quantite = value.toInt();
      });
      _calculateTotal();
    }
  }

  void _addOutilQuantity(LigneOutil ligne) {
    int index = lignesOutils.indexWhere((l) => l.id == ligne.id);
    if (index != -1) {
      setState(() {
        lignesOutils[index].quantite += 1;
      });
      _calculateTotal();
    }
  }

  void _removeOutilQuantity(LigneOutil ligne) {
    int index = lignesOutils.indexWhere((l) => l.id == ligne.id);
    if (index != -1) {
      if (lignesOutils[index].quantite > 1) {
        setState(() {
          lignesOutils[index].quantite -= 1;
        });
      } else {
        setState(() {
          lignesOutils.removeAt(index);
        });
      }
      _calculateTotal();
    }
  }

  void _removeOutil(LigneOutil outil) {
    setState(() {
      if (lignesOutils.contains(outil)) {
        lignesOutils.remove(outil);
      }
    });
    _calculateTotal();
  }

  void updateSelectionArticle(LigneArticle l) {
    setState(() {
      final index = lignesArticles
          .indexWhere((ligne) => ligne.article.id == l.article.id);
      if (index != -1) {
        lignesArticles[index].quantite += 1;
      } else {
        lignesArticles.add(l);
      }
    });
    _calculateTotal();
  }

  void updateSelectionOutil(LigneOutil l) {
    final i = lignesOutils.length + DateTime.now().millisecondsSinceEpoch;
    l.id = i;
    setState(() {
      lignesOutils.add(l);
    });
    _calculateTotal();
  }

  void updateSelectionType(TypeService t) {
    setState(() {
      typesServices.add(t);
      for (TypeArticle i in t.articleTypeList ?? []) {
        final index =
            lignesArticles.indexWhere((l) => l.article.id == i.article.id);
        if (index == -1) {
          lignesArticles.add(
            LigneArticle(
              article: i.article,
              quantite: 1,
              parentId: t.id,
              montant: i.article.prixVente,
            ),
          );
        } else {
          lignesArticles[index].quantite += 1;
        }
      }
      for (TypeOutil i in t.outilTypeList ?? []) {
        final index = lignesOutils.indexWhere((l) => l.outil.id == i.outil.id);
        if (index == -1) {
          lignesOutils.add(
            LigneOutil(
              outil: i.outil,
              quantite: 1,
              parentId: t.id,
              montant: i.tarifUsager ?? 0.0,
              applyTarif: true,
            ),
          );
        } else {
          lignesOutils[index].quantite += 1;
        }
      }
    });
    _calculateTotal();
  }

  void _editQuantity(LigneArticle ligne, double value) {
    int index =
        lignesArticles.indexWhere((l) => l.article.id == ligne.article.id);
    if (index != -1) {
      setState(() {
        lignesArticles[index].quantite = value.toInt();
      });
      _calculateTotal();
    }
  }

  void _adjustOccurrences(TypeService typeService, int count) {
    removeTypeOutil(typeService);
    setState(() {
      typesServices.removeWhere((e) => e.id == typeService.id);

      for (int i = 0; i < count; i++) {
        updateSelectionType(typeService);
      }
    });
  }

  void removeType(TypeService type) {
    setState(() {
      if (typesServices.contains(type)) {
        typesServices.removeWhere((e) => e.id == type.id);
        removeTypeOutil(type);
      }
    });
  }

  void removeTypeOutil(TypeService type) {
    setState(() {
      lignesOutils.removeWhere((outil) => outil.parentId == type.id);
      lignesArticles.removeWhere((article) => article.parentId == type.id);
    });
    _calculateTotal();
  }

  void removeSelection(LigneArticle l) {
    setState(() {
      final index = lignesArticles
          .indexWhere((ligne) => ligne.article.id == l.article.id);
      if (index != -1) {
        lignesArticles.removeAt(index);
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
    double totalLignesOutils = lignesOutils
        .where((ligne) => ligne.applyTarif == true)
        .fold(0.0, (sum, ligne) => sum + (ligne.montant ?? 0) * ligne.quantite);
    double totalLignesArticles = lignesArticles.fold(
        0.0, (sum, ligne) => sum + (ligne.montant ?? 0) * ligne.quantite);

    double total = totalLignesOutils + totalLignesArticles;

    if (_showOtherAmount) {
      total = double.tryParse(_montantController.text) ?? 0.0;
    } else {
      double taxe = _taxeInPercent
          ? (total * (double.tryParse(_taxeController.text) ?? 0.0) / 100)
          : double.tryParse(_taxeController.text) ?? 0.0;

      double remise = _remiseInPercent
          ? (total * (double.tryParse(_remiseController.text) ?? 0.0) / 100)
          : double.tryParse(_remiseController.text) ?? 0.0;

      total += taxe - remise;
    }

    setState(() {
      totalErrorMessage = "";
      _totalLignesOutils = totalLignesOutils;
      _totalLignesArticles = totalLignesArticles;
      _total = total;
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
    String libelle, {
    LigneArticle? article,
    Function(LigneArticle article, double value)? updateArticleValue,
    TypeService? type,
    Function(TypeService type, int value)? updateOccurences,
    LigneOutil? outil,
    Function(LigneOutil outil, double value)? updateOutilValue,
  }) async {
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
                final newValue = double.parse(_valueController.text);
                Navigator.of(dialogContext).pop();
                if (outil != null && updateOutilValue != null) {
                  updateOutilValue(outil, newValue);
                  _valueController.clear();
                }
                if (article != null && updateArticleValue != null) {
                  updateArticleValue(article, newValue);
                  _valueController.clear();
                }
                if (type != null && updateOccurences != null) {
                  updateOccurences(type, newValue.toInt());
                  _valueController.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _enregistrer(String status) async {
    if (client != null && _total > 0) {
      setState(() {
        _isLoading = true;
      });
      final Service newService = Service(
        id: 0,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        articles: lignesArticles,
        typeServices: typesServices,
        client: client!,
        traiteur: Employer(id: 0, nom: "", prenom: ""),
        outils: lignesOutils,
        total: _total,
        remise:
            !_showRemise ? 0 : (double.tryParse(_remiseController.text) ?? 0.0),
        designationRemise: _designationRemiseController.text.isEmpty
            ? null
            : _designationRemiseController.text,
        remiseInPercent: _remiseInPercent,
        taxe: !_showTaxe ? 0 : (double.tryParse(_taxeController.text) ?? 0.0),
        designationTaxe: _designationTaxeController.text.isEmpty
            ? null
            : _designationTaxeController.text,
        taxeInPercent: _taxeInPercent,
        numFacture: "",
        status: status,
      );

      final result = await sendService(newService);

      setState(() {
        _isLoading = false;
      });
      if (result['status']) {
        setState(() {
          _isLoading = false;
          _designationTaxeController.clear();
          _descriptionController.clear();
          _montantController.text = '0';
          _remiseController.text = '0';
          _designationRemiseController.clear();
          _designationTaxeController.clear();
          _valueController.clear();
          client = null;
          typesServices.clear();
          lignesArticles.clear();
          lignesOutils.clear();
          _totalLignesArticles = 0.0;
          _totalLignesOutils = 0.0;
          _total = 0.0;
          _showRemise = false;
          _showTaxe = false;
          _showOtherAmount = false;
        });
      }
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
      if (_total <= 0) {
        setState(() {
          totalErrorMessage =
              "Veuillez bien vérifier vos Prix, Remises et Taxes.";
        });
      }
    }
  }

  Future<void> _modifier(String status) async {
    if (client != null && _total > 0) {
      setState(() {
        _isLoading = true;
      });
      final Service newService = Service(
        id: widget.editableService?.id ?? 0,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        articles: lignesArticles,
        typeServices: typesServices,
        client: client!,
        traiteur: Employer(id: 0, nom: "", prenom: ""),
        outils: lignesOutils,
        total: _total,
        remise:
            !_showRemise ? 0 : (double.tryParse(_remiseController.text) ?? 0.0),
        designationRemise: _designationRemiseController.text.isEmpty
            ? null
            : _designationRemiseController.text,
        remiseInPercent: _remiseInPercent,
        taxe: !_showTaxe ? 0 : (double.tryParse(_taxeController.text) ?? 0.0),
        designationTaxe: _designationTaxeController.text.isEmpty
            ? null
            : _designationTaxeController.text,
        taxeInPercent: _taxeInPercent,
        numFacture: "",
        status: status,
      );

      final result =
          await updateService(newService, widget.editableService?.id ?? 0);

      setState(() {
        _isLoading = false;
      });
      if (result['status']) {
        setState(() {
          _isLoading = false;
          _designationTaxeController.clear();
          _descriptionController.clear();
          _montantController.text = '0';
          _remiseController.text = '0';
          _designationRemiseController.clear();
          _designationTaxeController.clear();
          _valueController.clear();
          client = null;
          typesServices.clear();
          lignesArticles.clear();
          lignesOutils.clear();
          _totalLignesArticles = 0.0;
          _totalLignesOutils = 0.0;
          _total = 0.0;
          _showRemise = false;
          _showTaxe = false;
          _showOtherAmount = false;
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
      }
    } else {
      if (client == null) {
        setState(() {
          clientErrorMessage = "Veuillez sélectionner un client.";
        });
      }
      if (_total <= 0) {
        setState(() {
          totalErrorMessage =
              "Veuillez bien vérifier vos Prix, Remises et Taxes.";
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
                              
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                                child: typeSelect(),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                                child: outilSelect(),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                                child: articleSelect(),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  
                                  color: Provider.of<ThemeProvider>(context)
                                      .themeData
                                      .colorScheme
                                      .primary,
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: TextFormField(
                                      controller: _descriptionController,
                                      cursorColor:
                                          Provider.of<ThemeProvider>(context)
                                              .themeData
                                              .colorScheme
                                              .tertiary,
                                      decoration: InputDecoration(
                                        labelText: "Description",
                                        border: OutlineInputBorder(),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        labelStyle: TextStyle(
                                          color: Provider.of<ThemeProvider>(
                                                  context)
                                              .themeData
                                              .colorScheme
                                              .tertiary,
                                        ),
                                      ),
                                      maxLines: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              
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

  Widget articleSelect() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      
      color: Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              initiallyExpanded: expanded,
              iconColor: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .tertiary,
              collapsedIconColor: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .tertiary,
              shape: Border.all(style: BorderStyle.none),
              tilePadding: EdgeInsets.symmetric(horizontal: 8.0),
              childrenPadding: EdgeInsets.symmetric(
                horizontal: .0,
                vertical: 8.0,
              ),
              title: Row(
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
                    '${_totalLignesArticles.toStringAsFixed(0)} f',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              children: [
                SizedBox(height: 16.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...List.generate(
                      lignesArticles.length,
                      (index) {
                        final ligne = lignesArticles[index];
                        return _ligneCard(ligne);
                      },
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _option = ArticleSelection(
                            updateSelection: (LigneArticle l) =>
                                updateSelectionArticle(l),
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
          ],
        ),
      ),
    );
  }

  Widget outilSelect() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      
      color: Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              initiallyExpanded: expanded,
              iconColor: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .tertiary,
              collapsedIconColor: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .tertiary,
              shape: Border.all(style: BorderStyle.none),
              tilePadding: EdgeInsets.symmetric(horizontal: 8.0),
              childrenPadding: EdgeInsets.symmetric(
                horizontal: .0,
                vertical: 8.0,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Outils Utilisés',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_totalLignesOutils.toStringAsFixed(0)} f',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    double totalWidth = constraints.maxWidth;
                    return Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ...List.generate(
                          lignesOutils.length,
                          (index) {
                            final ligne = lignesOutils[index];
                            return _buildOutilCard(
                              outil: ligne,
                              width: (totalWidth - 16.0) / 3,
                            );
                          },
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _option = OutilSelection(
                                updateOutilList: (LigneOutil l) =>
                                    updateSelectionOutil(l),
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
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget typeSelect() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      
      color: Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              initiallyExpanded: expanded,
              iconColor: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .tertiary,
              collapsedIconColor: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .tertiary,
              shape: Border.all(style: BorderStyle.none),
              tilePadding: EdgeInsets.symmetric(horizontal: 8.0),
              childrenPadding: EdgeInsets.symmetric(
                horizontal: .0,
                vertical: 8.0,
              ),
              title: Text(
                'Types de Service',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    double totalWidth = constraints.maxWidth;
                    return Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ...typesServices.toSet().map(
                              (ligne) => _buildTypeCard(
                                typeService: ligne,
                                width: (totalWidth - 16.0) / 3,
                              ),
                            ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _option = TypeSelection(
                                updateSelection: (TypeService t) =>
                                    updateSelectionType(t),
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
                    );
                  },
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
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Fixer le prix',
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
                          value: _showOtherAmount,
                          onChanged: (bool? value) {
                            setState(() {
                              _showOtherAmount = value ?? false;
                              _showRemise = false;
                              _showTaxe = false;
                            });
                            _remiseController.text = '0';
                            _taxeController.text = '0';
                            _montantController.text = '0';
                            _calculateTotal();
                          },
                        ),
                      ],
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
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
                          onChanged: _showOtherAmount
                              ? null
                              : (bool? value) {
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
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
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
                          onChanged: _showOtherAmount
                              ? null
                              : (bool? value) {
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
                if (_showOtherAmount) ...[
                  const SizedBox(height: 8.0),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "ATTENTION: Tous les autres frais seront abandonnés!",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _montantController,
                    cursorColor: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .tertiary,
                    decoration: InputDecoration(
                      labelText: "Montant",
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
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                    ],
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() {
                          _montantController.text = '0';
                        });
                      }
                      _calculateTotal();
                    },
                  ),
                ],
                if (_showTaxe) ...[
                  const SizedBox(height: 16.0),
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
                          controller: _designationTaxeController,
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
                if (_showRemise) ...[
                  const SizedBox(height: 16.0),
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
                          controller: _designationRemiseController,
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
                  widget.editableService != null
                      ? _modifier('complete')
                      : _enregistrer('complete');
                }),
                const SizedBox(width: 16.0),
                _buildActionButton(Icons.save, 'Sauvegarder', false, () {
                  widget.editableService != null
                      ? _modifier('en_attente')
                      : _enregistrer('en_attente');
                }),
                const SizedBox(width: 16.0),
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

  Widget _ligneCard(LigneArticle ligne) {
    return LayoutBuilder(builder: (context, constraints) {
      double totalWidth = constraints.maxWidth;
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        
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
                              article: ligne,
                              updateArticleValue: _editQuantity,
                            );
                          },
                        ),
                        Text(
                          "${ligne.quantite} x ${formatMontant(ligne.article.prixVente ?? 0)} f",
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
                      ((ligne.article.prixVente ?? 0) * ligne.quantite)
                          .toStringAsFixed(0),
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

  Widget _buildOutilCard({
    required LigneOutil outil,
    required double width,
  }) {
    return Stack(
      children: [
        SizedBox(
          width: width,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            margin: EdgeInsets.all(0.0),
            color: Colors.blueGrey[200],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outil.outil.libelle,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Tarif à l'unité (${outil.montant?.toStringAsFixed(0) ?? 0}F)",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          InkWell(
                            onTap: () {
                              showNumericInputDialog(
                                context,
                                'Tarif à l\'unité',
                                outil: outil,
                                updateOutilValue: _editTarif,
                              );
                            },
                            child: Icon(
                              Icons.edit_square,
                              size: 18.0,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Appliquer le tarif',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Checkbox(
                        activeColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .secondary,
                        value: outil.applyTarif ?? false,
                        onChanged: (bool? value) {
                          _toggleTarif(outil);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Quantité',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              showNumericInputDialog(
                                context,
                                'Quantité',
                                outil: outil,
                                updateOutilValue: _editQte,
                              );
                            },
                            child: Icon(
                              Icons.edit_square,
                              size: 18.0,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        alignment: WrapAlignment.spaceAround,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            radius: 12,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.remove,
                                size: 16,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _removeOutilQuantity(outil);
                              },
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            '${outil.quantite}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            radius: 12,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.add,
                                  size: 16, color: Colors.white),
                              onPressed: () {
                                _addOutilQuantity(outil);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 16.0,
          right: 16.0,
          child: CircleAvatar(
            backgroundColor: Colors.blueGrey,
            radius: 12,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.remove, size: 16, color: Colors.white),
              onPressed: () {
                _removeOutil(outil);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required TypeService typeService,
    required double width,
  }) {
    return Stack(
      children: [
        SizedBox(
          width: width,
          height: 110.0,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            margin: EdgeInsets.all(0.0),
            color: Colors.blueGrey[200],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    typeService.libelle,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "x ${typesServices.where((e) => e.id == typeService.id).length}",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          InkWell(
                            onTap: () {
                              showNumericInputDialog(
                                context,
                                'Tarif à l\'unité',
                                type: typeService,
                                updateOccurences: _adjustOccurrences,
                              );
                            },
                            child: Icon(
                              Icons.edit_square,
                              size: 18.0,
                              color: Colors.blueGrey,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 16.0,
          right: 16.0,
          child: CircleAvatar(
            backgroundColor: Colors.blueGrey,
            radius: 12,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.remove, size: 16, color: Colors.white),
              onPressed: () {
                removeType(typeService);
              },
            ),
          ),
        ),
      ],
    );
  }
}
