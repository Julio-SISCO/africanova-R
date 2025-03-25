import 'package:africanova/controller/categorie_controller.dart';
import 'package:africanova/database/categorie.dart';
import 'package:africanova/provider/permissions_providers.dart';

import 'package:africanova/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class CategorieForm extends StatefulWidget {
  final Categorie? editableCategorie;
  const CategorieForm({super.key, this.editableCategorie});

  @override
  State<CategorieForm> createState() => _CategorieFormState();
}

class _CategorieFormState extends State<CategorieForm> {
  final TextEditingController codeController = TextEditingController();
  final TextEditingController libelleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    if (widget.editableCategorie != null) {
      final categorie = widget.editableCategorie;

      setState(() {
        codeController.text = categorie!.code ?? '';
        libelleController.text = categorie.libelle ?? '';
        descriptionController.text = categorie.description ?? '';
      });
    }
  }

  void _submitEditionForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String? code = codeController.text;
      final String libelle = libelleController.text;
      final String description = descriptionController.text;

      final result = await updateCategorie(
        code: code,
        libelle: libelle,
        description: description,
        id: widget.editableCategorie!.id!,
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
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String? code = codeController.text;
      final String libelle = libelleController.text;
      final String description = descriptionController.text;

      final result = await storeCategorie(
        code: code,
        libelle: libelle,
        description: description,
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
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.15,
        ),
        child: FutureBuilder<bool>(
          future: hasPermission('creer categories'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            bool canSaveSale = snapshot.data ?? false;
            return !canSaveSale
                ? Center(
                    child: Text(
                      'Désolé! Vous n\'êtes pas autorisés à créer une catégorie.',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Card(
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: EdgeInsets.all(16.0 * 2),
                      child: Form(
                        key: _formKey,
                        child: _desktopForm(context),
                      ),
                    ),
                  );
          },
        ),
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
                  labelText: 'Code de la catégorie',
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
                  labelText: 'Libellé de la catégorie',
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
            labelText: 'Description de la catégorie',
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
                    if (widget.editableCategorie == null) {
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
}
