import 'package:africanova/controller/image_url_controller.dart';
import 'package:africanova/controller/service_controller.dart';
import 'package:africanova/database/article.dart';
import 'package:africanova/database/type_article.dart';
import 'package:africanova/database/outil.dart';
import 'package:africanova/database/type_outil.dart';
import 'package:africanova/database/type_service.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/services/service_table.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class ServiceTypeForm extends StatefulWidget {
  final Function(Widget content) changeContent;
  final Function(Widget) switchView;
  final TypeService? serviceType;
  const ServiceTypeForm({
    super.key,
    this.serviceType,
    required this.changeContent,
    required this.switchView,
  });

  @override
  State<ServiceTypeForm> createState() => _ServiceTypeFormState();
}

class _ServiceTypeFormState extends State<ServiceTypeForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _libelleController;
  late TextEditingController _descriptionController;
  final TextEditingController _valueController = TextEditingController();
  List<Outil> _outils = [];
  List<TypeOutil> _selectedOutils = [];
  List<Article> _articles = [];
  List<TypeArticle> _selectedArticles = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _libelleController =
        TextEditingController(text: widget.serviceType?.libelle ?? '');
    _descriptionController =
        TextEditingController(text: widget.serviceType?.description ?? '');

    _outils = Hive.box<Outil>('outilBox').values.toList();
    _articles = Hive.box<Article>('articleBox').values.toList();
    _loadOutils();
  }

  void _loadOutils() {
    if (widget.serviceType != null) {
      setState(() {
        _selectedOutils = widget.serviceType?.outilTypeList ?? [];
        _selectedArticles = widget.serviceType?.articleTypeList ?? [];
      });
    }
  }

  void _toggleOutil(Outil outil) {
    final dateId = DateTime.now().millisecondsSinceEpoch;
    final outilType = TypeOutil(
      id: (dateId + outil.id),
      outil: outil,
      tarifUsager: 0.0,
    );
    setState(() {
      _selectedOutils.add(outilType);
    });
  }

  void _toggleArticle(Article article) {
    final dateId = DateTime.now().millisecondsSinceEpoch;
    final articleType = TypeArticle(
      id: (dateId + (article.id ?? 0)),
      article: article,
      tarifUsager: article.prixVente,
    );
    setState(() {
      _selectedArticles.add(articleType);
    });
  }

  void _removeOutil(TypeOutil outil) {
    if (_selectedOutils.contains(outil)) {
      setState(() {
        _selectedOutils.remove(outil);
      });
    }
  }

  void _removeArticle(TypeArticle article) {
    if (_selectedArticles.contains(article)) {
      setState(() {
        _selectedArticles.remove(article);
      });
    }
  }

  void _editTarif(double value, {TypeOutil? outil, TypeArticle? article}) {
    if (outil != null) {
      int index = _selectedOutils.indexWhere((o) => o.id == outil.id);
      if (index != -1) {
        setState(() {
          _selectedOutils[index].tarifUsager = value;
        });
      }
    }
    if (article != null) {
      int index = _selectedArticles.indexWhere((a) => a.id == article.id);
      if (index != -1) {
        setState(() {
          _selectedArticles[index].tarifUsager = value;
        });
      }
    }
  }

  Future<void> showNumericInputDialog(
    BuildContext context,
    String libelle,
    Function(
      double value, {
      TypeOutil? outil,
      TypeArticle? article,
    }) updateValue, {
    TypeOutil? outil,
    TypeArticle? article,
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
                final newTarif = double.parse(_valueController.text);
                Navigator.of(dialogContext).pop();
                if (outil != null) {
                  updateValue(outil: outil, newTarif);
                }
                if (article != null) {
                  updateValue(article: article, newTarif);
                }
                _valueController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveServiceType() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final newType = TypeService(
        id: 0,
        libelle: _libelleController.text,
        description: _descriptionController.text,
        outilTypeList: _selectedOutils,
        articleTypeList: _selectedArticles,
      );
      Map<String, dynamic> result = {};
      if (widget.serviceType != null) {
        result =
            await updateTypeService(newType, (widget.serviceType?.id ?? 0));
      } else {
        result = await sendTypeService(newType);
      }
      if (result['status']) {
        setState(() {
          _formKey.currentState!.reset();
          _libelleController.clear();
          _descriptionController.clear();
          _selectedOutils.clear();
          _selectedArticles.clear();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
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
          margin: EdgeInsets.all(0.0),
          
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  
                  color: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .primary,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _libelleController,
                            cursorColor: Provider.of<ThemeProvider>(context)
                                .themeData
                                .colorScheme
                                .tertiary,
                            decoration: InputDecoration(
                              labelText: 'Libellé',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Le libellé est requis.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: _descriptionController,
                            cursorColor: Provider.of<ThemeProvider>(context)
                                .themeData
                                .colorScheme
                                .tertiary,
                            decoration: InputDecoration(
                              labelText: 'Description (optionnelle)',
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
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16.0),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              double totalWidth = constraints.maxWidth;
                              return Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                alignment: WrapAlignment.start,
                                children: [
                                  ...List.generate(
                                    _selectedOutils.length,
                                    (index) => _buildOutilCard(
                                        outil: _selectedOutils[index],
                                        width: (totalWidth - 16) / 2),
                                  ),
                                  ...List.generate(
                                    _selectedArticles.length,
                                    (index) => _buildOutilCard(
                                        article: _selectedArticles[index],
                                        width: (totalWidth - 16) / 2),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                height: 40.0,
                                width: 140.0,
                                child: TextButton(
                                  onPressed: () =>
                                      widget.changeContent(ServiceTable(
                                    switchView: (Widget w) =>
                                        widget.switchView(w),
                                  )),
                                  style: TextButton.styleFrom(
                                    
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                  ),
                                  child: Text(
                                    "Annuler",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Provider.of<ThemeProvider>(context)
                                          .themeData
                                          .colorScheme
                                          .tertiary,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 40.0,
                                width: 140.0,
                                child: TextButton(
                                  onPressed: _saveServiceType,
                                  style: TextButton.styleFrom(
                                    
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    backgroundColor: Colors.blueGrey[200],
                                  ),
                                  child: Text(
                                    "Enregistrer",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Provider.of<ThemeProvider>(context)
                                          .themeData
                                          .colorScheme
                                          .surface,
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
                ),
              ),
              Expanded(
                flex: 3,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  
                  color: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .primary,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double totalWidth = constraints.maxWidth;
                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          alignment: WrapAlignment.start,
                          children: [
                            ...List.generate(
                              _outils.length,
                              (index) => InkWell(
                                onTap: () {
                                  _toggleOutil(_outils[index]);
                                },
                                hoverColor: Colors.transparent,
                                child: _outilCard(
                                    outil: _outils[index],
                                    width: (totalWidth - 16) / 3),
                              ),
                            ),
                            ...List.generate(
                              _articles.length,
                              (index) => InkWell(
                                onTap: () {
                                  _toggleArticle(_articles[index]);
                                },
                                hoverColor: Colors.transparent,
                                child: _outilCard(
                                    article: _articles[index],
                                    width: (totalWidth - 16) / 3),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: CircularProgressIndicator(
                color: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .secondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _outilCard({Outil? outil, required double width, Article? article}) {
    if (outil != null) {
      return SizedBox(
        width: width,
        height: 100.0,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          elevation: 0,
          margin: EdgeInsets.all(0.0),
          color: Colors.blueGrey[200],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  outil.libelle,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (article != null) {
      return SizedBox(
        width: width,
        height: 180.0,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          elevation: 0,
          margin: EdgeInsets.all(0.0),
          color: Colors.blueGrey[200],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4.0),
                    topRight: Radius.circular(4.0),
                  ),
                  child: article.images!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: buildUrl(article.images![0].path),
                          height: MediaQuery.of(context).size.height * .3,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.fill,
                          placeholder: (context, url) =>
                              LinearProgressIndicator(
                            color: Colors.grey.withOpacity(.2),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : Image.asset(
                          'assets/images/placeholder.png',
                          height: MediaQuery.of(context).size.height * .3,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.fill,
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.libelle!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${article.prixVente} f',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${article.stock} disponible',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  Widget _buildOutilCard(
      {TypeOutil? outil, TypeArticle? article, required double width}) {
    if (outil != null) {
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
                              "Tarif à l'unité (${outil.tarifUsager?.toStringAsFixed(0) ?? 0}F)",
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
                                  _editTarif,
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
                  _removeOutil(outil);
                },
              ),
            ),
          ),
        ],
      );
    }
    if (article != null) {
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
                      article.article.libelle ?? "",
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
                              "Tarif à l'unité (${article.tarifUsager?.toStringAsFixed(0) ?? 0}F)",
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
                                  article: article,
                                  _editTarif,
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
                  _removeArticle(article);
                },
              ),
            ),
          ),
        ],
      );
    }
    return Container();
  }
}
