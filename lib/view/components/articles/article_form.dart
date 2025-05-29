import 'dart:io';

import 'package:africanova/controller/article_controller.dart';
import 'package:africanova/controller/image_url_controller.dart';
import 'package:africanova/database/article.dart';
import 'package:africanova/database/categorie.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/util/image_picker_manager.dart';
import 'package:africanova/widget/dialogs.dart';
import 'package:africanova/widget/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Categorie? _selectedCategorie;
  String categorieError = '';
  Article? editableArticle;

  @override
  void initState() {
    super.initState();

    categoriesController.text = 1.toString();
    _loadCategories();

    _initData();
  }

  void _initData() {
    if (widget.editableArticle != null) {
      setState(() {
        editableArticle = widget.editableArticle;
        codeController.text = editableArticle!.code ?? '';
        libelleController.text = editableArticle?.libelle ?? '';
        descriptionController.text = editableArticle?.description ?? '';
        purchasePriceController.text =
            editableArticle?.prixAchat.toString() ?? '';
        salePriceController.text = editableArticle?.prixVente.toString() ?? '';
        quantityController.text = editableArticle?.stock.toString() ?? '';
        _selectedCategorie = editableArticle?.categorie;
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
    final result = await supprimerImage(id);

    if (result['status'] == true) {
      setState(() {
        editableArticle!.images!.removeAt(index);
      });
    }
    Get.back();
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

  void _submitEditionForm() async {
    if (_formKey.currentState!.validate() &&
        (selectedImage.length + editableArticle!.images!.length) > 0) {
      setState(() {
        isLoading = true;
      });
      String? code = codeController.text;
      final String libelle = libelleController.text;
      final String description = descriptionController.text;
      final double? prixAchat = double.tryParse(purchasePriceController.text);
      final double? prixVente = double.tryParse(salePriceController.text);
      final int categorie = _selectedCategorie?.id ?? 0;
      final List<File> images = selectedImage;

      final result = await updateArticle(
        code: code,
        libelle: libelle,
        description: description,
        prixAchat: prixAchat,
        prixVente: prixVente,
        categorie: categorie,
        images: images,
        id: editableArticle!.id!,
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
        editableArticle = null;
      }
      setState(() {
        isLoading = false;
      });
    } else {
      if ((selectedImage.isNotEmpty) ||
          (editableArticle != null &&
              editableArticle!.images != null &&
              editableArticle!.images!.isNotEmpty)) {
      } else {
        Get.snackbar(
          '',
          'Associez une image à l\'article',
          titleText: SizedBox.shrink(),
          messageText: Center(
            child: Text('Associez une image à l\'article'),
          ),
          maxWidth: 300,
          snackPosition: SnackPosition.BOTTOM,
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
      final int categorie = _selectedCategorie?.id ?? 0;
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
    return _buildColumn();
  }

  Widget _buildColumn() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      color: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActionButtons(),
                SizedBox(height: 24.0),
                _buildLabelle(),
                SizedBox(height: 24.0),
                _buildCategoryDropdown(),
                SizedBox(height: 24.0),
                _buildMontantField(),
                SizedBox(height: 24.0),
                _buildDescriptionField(
                  "Description",
                  descriptionController,
                  3,
                  null,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: _buildFilePicker(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMontantField() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: constraints.maxWidth * 0.48,
              child: TextFormField(
                controller: purchasePriceController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: const BorderSide(),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
                  labelText: "Prix d'achat",
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final n = num.tryParse(value);
                  if (n == null) {
                    return 'Veuillez entrer un montant valide';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              width: constraints.maxWidth * 0.48,
              child: TextFormField(
                controller: salePriceController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: const BorderSide(),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
                  labelText: "Prix de vente",
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final n = num.tryParse(value);
                  if (n == null) {
                    return 'Veuillez entrer un montant valide';
                  }
                  return null;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDescriptionField(String label, controller, int? l, validator) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
      ),
      validator: validator,
      maxLines: l ?? 1,
    );
  }

  Widget _buildFilePicker() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildButton(
          context: context,
          onPressed: ((selectedImage.length +
                      (editableArticle?.images?.length ?? 0)) >=
                  3)
              ? null
              : () async {
                  await _pickImage();
                },
          libelle: "Ajouter unne image",
          icon: Icons.add_a_photo_outlined,
          width: 200,
          color: const Color.fromARGB(255, 5, 202, 133),
        ),
        SizedBox(height: 16.0),
        if (imageError != null && imageError!.isNotEmpty)
          Text(
            imageError!,
            style: TextStyle(color: Colors.red[700]),
          ),
        SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 16.0,
          ),
          child: _displayImages(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return _buildButton(
      context: context,
      onPressed: isLoading
          ? null
          : () {
              if (editableArticle == null) {
                _submitForm();
              } else {
                _submitEditionForm();
              }
            },
      libelle: "Enregistrer",
      icon: Icons.save,
      width: 120,
      color: const Color.fromARGB(255, 5, 202, 133).withOpacity(0.6),
    );
  }

  Widget _displayImages() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (editableArticle != null && editableArticle!.images != null)
          for (int i = 0; i < editableArticle!.images!.length; i++) ...[
            Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Image.network(
                    buildUrl(editableArticle!.images![i].path),
                    height: 150,
                    width: 220,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: -12,
                  right: 5,
                  child: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      showCancelConfirmationDialog(
                        context,
                        () {
                          _deleteImage(
                              context, editableArticle!.images![i].id, i);
                        },
                        'Êtes-vous sûr de vouloir annuler cette image ?',
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
          ],
        for (int i = 0; i < selectedImage.length; i++) ...[
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  right: 16.0,
                ),
                child: Image.file(
                  selectedImage[i],
                  height: 150,
                  width: 220,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: -12,
                right: 5,
                child: IconButton(
                  icon: Icon(
                    Icons.cancel,
                    color:
                        const Color.fromARGB(255, 5, 202, 133).withOpacity(0.7),
                  ),
                  onPressed: () => _removeImage(i),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
        ],
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDropdownContainer(constraints),
            _buildquantityContainer(constraints),
          ],
        );
      },
    );
  }

  Widget _buildLabelle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: constraints.maxWidth * 0.48,
              child: _buildDescriptionField(
                  "Code de l'article", codeController, null, null),
            ),
            SizedBox(
                width: constraints.maxWidth * 0.48,
                child: _buildDescriptionField(
                  "Libellé de l'article",
                  libelleController,
                  1,
                  (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un libellé';
                    }
                    return null;
                  },
                )),
          ],
        );
      },
    );
  }

  Widget _buildDropdownContainer(BoxConstraints constraints) {
    return SizedBox(
      width: constraints.maxWidth * 0.48,
      child: buildDropdownA<Categorie>(
        "Catégorie",
        _categories,
        _selectedCategorie,
        Colors.grey.withOpacity(0.1),
        false,
        (value) {
          setState(() {
            categorieError = '';
            _selectedCategorie = value;
          });
        },
      ),
    );
  }

  Widget _buildquantityContainer(BoxConstraints constraints) {
    return SizedBox(
      width: constraints.maxWidth * 0.48,
      child: TextFormField(
        controller: quantityController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
          labelText: "Quantité",
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\d*')),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez entrer un montant';
          }
          final n = num.tryParse(value);
          if (n == null) {
            return 'Veuillez entrer un montant valide';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String libelle,
    required IconData icon,
    required VoidCallback? onPressed,
    double? width,
    Color? color,
  }) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SizedBox(
          height: 40,
          width: width ?? double.infinity,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: !isLoading
                  ? const Color.fromARGB(255, 5, 202, 133).withOpacity(0.6)
                  : color ?? themeProvider.themeData.colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0)),
            ),
            onPressed: isLoading ? null : onPressed,
            icon: Icon(icon, size: 20, color: Colors.white),
            label: Text(
              libelle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
