import 'package:africanova/controller/categorie_controller.dart';
import 'package:africanova/database/categorie.dart';
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
                _buildDescriptionField(
                  "Description",
                  descriptionController,
                  3,
                  null,
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildActionButtons() {
    return _buildButton(
      context: context,
      onPressed: isLoading
          ? null
          : () {
              if (widget.editableCategorie == null) {
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

  Widget _buildLabelle() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: constraints.maxWidth * 0.48,
              child: _buildDescriptionField(
                  "Code de la categorie", codeController, null, null),
            ),
            SizedBox(
                width: constraints.maxWidth * 0.48,
                child: _buildDescriptionField(
                  "Libellé de la categorie",
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
