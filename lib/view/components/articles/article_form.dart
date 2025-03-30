import 'dart:io';

import 'package:africanova/controller/article_controller.dart';
import 'package:africanova/controller/image_url_controller.dart';
import 'package:africanova/database/article.dart';
import 'package:africanova/database/categorie.dart';
import 'package:africanova/provider/permissions_providers.dart';

import 'package:africanova/static/theme.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/util/image_picker_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ArticleForm extends StatefulWidget {
  final Article? editableArticle;
  const ArticleForm({super.key, this.editableArticle});

  @override
  State<ArticleForm> createState() => _ArticleFormState();
}

class _ArticleFormState extends State<ArticleForm> {
  final TextEditingController codeController = TextEditingController();
  final TextEditingController libelleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController categoriesController = TextEditingController();

  String? imageError;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  List<File> selectedImage = [];
  final ImagePicker _picker = ImagePicker();
  final List<Categorie> _categories = [];
  int? _selectedCategorie;

  @override
  void initState() {
    super.initState();

    categoriesController.text = 1.toString();
    _loadCategories();

    _initData();
  }

  void _initData() {
    if (widget.editableArticle != null) {
      final article = widget.editableArticle;

      setState(() {
        codeController.text = article!.code ?? '';
        libelleController.text = article.libelle ?? '';
        descriptionController.text = article.description ?? '';
        purchasePriceController.text = article.prixAchat.toString();
        salePriceController.text = article.prixVente.toString();
        quantityController.text = article.stock.toString();
        _selectedCategorie = article.categorie?.id ?? 0;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImage.removeAt(index);
    });
  }

  Future<void> _loadCategories() async {
    var box = Hive.box<Categorie>('categorieBox');
    List<Categorie> categories = box.values.toList();

    _categories.clear();
    for (var categorie in categories) {
      if (categorie.id != null && categorie.libelle != null) {
        _categories.add(categorie);
      }
    }
  }

  Future<void> _pickImage() async {
    final file = await getImageFromGallery(_picker);
    if (file != null) {
      setState(() {
        selectedImage.add(file);
        imageError = null;
      });
    }
  }

  void _deleteImage(BuildContext ctxt, int id, int index) async {
    showDialog(
      context: ctxt,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Voulez-vous vraiment supprimer cette image ?'),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () async {
                final result = await supprimerImage(id);

                if (result['status'] == true) {
                  setState(() {
                    widget.editableArticle!.images!.removeAt(index);
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
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _submitEditionForm() async {
    if (_formKey.currentState!.validate() &&
        (selectedImage.length + widget.editableArticle!.images!.length) > 0) {
      setState(() {
        isLoading = true;
      });
      String? code = codeController.text;
      final String libelle = libelleController.text;
      final String description = descriptionController.text;
      final double? prixAchat = double.tryParse(purchasePriceController.text);
      final double? prixVente = double.tryParse(salePriceController.text);
      final int categorie = _selectedCategorie!;
      final List<File> images = selectedImage;

      final result = await updateArticle(
        code: code,
        libelle: libelle,
        description: description,
        prixAchat: prixAchat,
        prixVente: prixVente,
        categorie: categorie,
        images: images,
        id: widget.editableArticle!.id!,
      );
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
      if (result['status'] == true) {
        codeController.clear();
        libelleController.clear();
        descriptionController.clear();
        quantityController.clear();
        purchasePriceController.clear();
        salePriceController.clear();
        categoriesController.clear();
        images.clear();
      }
      setState(() {
        isLoading = false;
      });
    } else {
      if ((selectedImage.isNotEmpty) ||
          (widget.editableArticle != null &&
              widget.editableArticle!.images != null &&
              widget.editableArticle!.images!.isNotEmpty)) {
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text('Associez une image à l\'article'),
            ),
          ),
        );
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && selectedImage.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      final int stock = int.parse(quantityController.text);
      String? code = codeController.text;
      final String libelle = libelleController.text;
      final String description = descriptionController.text;
      final double? prixAchat = double.tryParse(purchasePriceController.text);
      final double? prixVente = double.tryParse(salePriceController.text);
      final int categorie = _selectedCategorie!;
      final List<File> images = selectedImage;

      final result = await storeArticle(
        stock: stock,
        code: code,
        libelle: libelle,
        description: description,
        prixAchat: prixAchat,
        prixVente: prixVente,
        categorie: categorie,
        images: images,
      );
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
      if (result['status'] == true) {
        codeController.clear();
        libelleController.clear();
        descriptionController.clear();
        quantityController.clear();
        purchasePriceController.clear();
        salePriceController.clear();
        categoriesController.clear();
        images.clear();
      }
      setState(() {
        isLoading = false;
      });
    } else {
      if (_formKey.currentState!.validate()) {
        if (selectedImage.isEmpty) {
          setState(() {
            imageError = "Choisissez une image";
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.15),
      child: FutureBuilder<bool>(
        future: hasPermission('creer articles'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .secondary,
            ));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          bool canSaveSale = snapshot.data ?? false;
          return !canSaveSale
              ? Center(
                  child: Text(
                    'Désolé! Vous n\'êtes pas autorisés à créer un article.',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.03,
                    vertical: MediaQuery.of(context).size.height * 0.015,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0 * 2),
                    child: Form(key: _formKey, child: _desktopForm(context)),
                  ),
                );
        },
      ),
    );
  }

  Widget _desktopForm(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                cursorColor: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .tertiary,
                controller: codeController,
                decoration: InputDecoration(
                  labelText: 'Code de l\'article',
                  fillColor: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .primary,
                  floatingLabelStyle: TextStyle(
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .tertiary,
                  ),
                  filled: true,
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: TextFormField(
                controller: libelleController,
                cursorColor: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .tertiary,
                decoration: InputDecoration(
                  labelText: 'Libellé de l\'article',
                  filled: true,
                  fillColor: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .primary,
                  floatingLabelStyle: TextStyle(
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .tertiary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un libellé';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownButtonFormField<int?>(
                decoration: InputDecoration(
                  labelText: 'Catégorie',
                  fillColor: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .primary,
                  floatingLabelStyle: TextStyle(
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .tertiary,
                  ),
                  filled: true,
                ),
                value: _selectedCategorie,
                items: _categories.map((category) {
                  return DropdownMenuItem<int?>(
                    value: category.id,
                    child: Text(category.libelle!),
                  );
                }).toList(),
                onChanged: (value) {
                  categoriesController.text = _categories
                      .firstWhere((categorie) => categorie.id == value)
                      .libelle!;
                  setState(() {
                    _selectedCategorie = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner une catégorie';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: TextFormField(
                controller: quantityController,
                cursorColor: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .tertiary,
                decoration: InputDecoration(
                  labelText: 'Quantité en stock',
                  filled: true,
                  fillColor: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .primary,
                  floatingLabelStyle: TextStyle(
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .tertiary,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une quantité';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity < 0) {
                    return 'La quantité doit être supérieure ou égale à 0';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                cursorColor: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .tertiary,
                controller: purchasePriceController,
                decoration: InputDecoration(
                  labelText: 'Prix d\'achat',
                  fillColor: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .primary,
                  floatingLabelStyle: TextStyle(
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .tertiary,
                  ),
                  filled: true,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix d\'achat';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Le prix d\'achat doit être supérieur ou égal à 0';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: TextFormField(
                cursorColor: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .tertiary,
                controller: salePriceController,
                decoration: InputDecoration(
                  labelText: 'Prix de vente',
                  fillColor: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .primary,
                  floatingLabelStyle: TextStyle(
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .tertiary,
                  ),
                  filled: true,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix de vente';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Le prix de vente doit être supérieur ou égal à 0';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        _buildCameraButton(),
        if ((widget.editableArticle != null &&
                widget.editableArticle!.images != null &&
                widget.editableArticle!.images!.isNotEmpty) ||
            selectedImage.isNotEmpty)
          _displayImages(),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: descriptionController,
          cursorColor: Provider.of<ThemeProvider>(context)
              .themeData
              .colorScheme
              .tertiary,
          decoration: InputDecoration(
            fillColor: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .primary,
            floatingLabelStyle: TextStyle(
              color: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .tertiary,
            ),
            filled: true,
            labelText: 'Description de l\'article',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 30),
        SizedBox(
          height: 40,
          width: MediaQuery.of(context).size.width * .3,
          child: TextButton(
            style: TextButton.styleFrom(
              elevation: 2.0,
              backgroundColor: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .primary,
              foregroundColor: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .tertiary,
              side: BorderSide(
                width: 2.0,
                color: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .primary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: isLoading
                ? null
                : () {
                    if (widget.editableArticle == null) {
                      _submitForm();
                    } else {
                      _submitEditionForm();
                    }
                  },
            child: const Text(
              'Enregistrer',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      margin: const EdgeInsets.only(top: 6.0),
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: selectedImage.length < 3
                  ? () {
                      _pickImage();
                    }
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 40,
                  ),
                  Text(
                    ' Ajoutez une image',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              imageError ?? '',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _displayImages() {
    return Row(
      children: [
        const SizedBox(width: 16.0),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (widget.editableArticle != null &&
                    widget.editableArticle!.images != null)
                  for (int i = 0;
                      i < widget.editableArticle!.images!.length;
                      i++)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Image.network(
                            buildUrl(widget.editableArticle!.images![i].path),
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: -12,
                          right: 5,
                          child: IconButton(
                            icon: Icon(Icons.cancel, color: bgColor),
                            onPressed: () => _deleteImage(context,
                                widget.editableArticle!.images![i].id, i),
                          ),
                        ),
                      ],
                    ),
                for (int i = 0; i < selectedImage.length; i++)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 16.0,
                        ),
                        child: Image.file(
                          selectedImage[i],
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -12,
                        right: 5,
                        child: IconButton(
                          icon: Icon(Icons.cancel, color: Colors.blueGrey),
                          onPressed: () => _removeImage(i),
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
}
