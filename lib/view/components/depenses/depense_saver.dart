import 'dart:io';

import 'package:africanova/controller/depense_controller.dart';
import 'package:africanova/database/categorie_depense.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/approvisions/approvision_saver.dart';
import 'package:africanova/view/components/approvisions/approvision_table.dart';
import 'package:africanova/view/components/depenses/depense_table.dart';
import 'package:africanova/widget/dropdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class DepenseSaver extends StatefulWidget {
  const DepenseSaver({super.key});

  @override
  State<DepenseSaver> createState() => _DepenseSaverState();
}

class _DepenseSaverState extends State<DepenseSaver> {
  String selectedButton = "Dépense Standard";
  CategorieDepense? _selectedCategorieDepense;
  List<CategorieDepense> categories = [];
  DateTime selectedDate = DateTime.now();
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<File> fichiers = [];
  String categorieError = '';
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  Widget _view = Container();

  injectView(Widget w) {
    setState(() {
      _view = w;
    });
  }

  @override
  void initState() {
    super.initState();
    categories =
        Hive.box<CategorieDepense>('categorieDepenseBox').values.toList();
    _view = _buildLeftColumn();
  }

  void _submitForm(String status) async {
    if (_formKey.currentState!.validate() &&
        _selectedCategorieDepense != null) {
      setState(() => isLoading = true);

      final result = await storeDepense(
        montant: double.parse(_montantController.text),
        date: selectedDate,
        status: status,
        description: _descriptionController.text,
        categorie: _selectedCategorieDepense?.id ?? 0,
        fichiers: fichiers,
      );

      Get.snackbar('', result["message"],
          titleText: SizedBox.shrink(),
          messageText: Center(child: Text(result["message"])),
          maxWidth: 300,
          snackPosition: SnackPosition.BOTTOM);

      if (result['status'] == true) {
        _montantController.clear();
        _descriptionController.clear();
        fichiers.clear();
        setState(() {
          _selectedCategorieDepense = null;
          selectedDate = DateTime.now();
        });
      }

      setState(() => isLoading = false);
    } else {
      if (fichiers.isEmpty) {
        setState(() {
          categorieError = 'Veuillez choisir une catégorie';
        });
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'csv',
        'jpg',
        'jpeg',
        'png'
      ],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        fichiers.addAll(result.paths.map((path) => File(path!)).toList());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
        elevation: 0.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: _view,
              ),
              Expanded(
                flex: 2,
                child: _buildRightColumn(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
      elevation: 0.0,
      color: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildActionButtons(),
            SizedBox(height: 32.0),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      spacing: 8.0,
      children: [
        _buildButton(
          context: context,
          onPressed: () => _submitForm('en_attente'),
          libelle: "Enregistrer",
          icon: Icons.save,
          width: 120,
          color: const Color.fromARGB(255, 5, 202, 133).withOpacity(0.6),
        ),
        _buildButton(
          context: context,
          onPressed: () => _submitForm('valide'),
          libelle: "Valider",
          icon: Icons.done,
          width: 120,
          color: const Color.fromARGB(255, 5, 202, 133),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryDropdown(),
                _buildMontantField(),
                SizedBox(height: 24.0),
                _buildDescriptionField(),
              ],
            ),
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
    );
  }

  Widget _buildCategoryDropdown() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownContainer(constraints),
            _buildDatePicker(constraints),
          ],
        );
      },
    );
  }

  Widget _buildDropdownContainer(BoxConstraints constraints) {
    return SizedBox(
      width: constraints.maxWidth * 0.48,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDropdown<CategorieDepense>(
            "Catégorie de dépenses",
            categories,
            _selectedCategorieDepense,
            Colors.grey.withOpacity(0.1),
            false,
            (value) {
              setState(() {
                categorieError = '';
                _selectedCategorieDepense = value;
              });
            },
          ),
          Text(
            categorieError,
            style: TextStyle(color: Colors.red[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BoxConstraints constraints) {
    return SizedBox(
      width: constraints.maxWidth * 0.48,
      child: InkWell(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              selectedDate = pickedDate;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(2.0),
            color: Colors.grey.withOpacity(0.1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${selectedDate.toLocal()}".split(' ')[0],
                  style: const TextStyle(fontSize: 16)),
              const Icon(Icons.calendar_today),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMontantField() {
    return TextFormField(
      controller: _montantController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.0),
          borderSide: const BorderSide(),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        labelText: "Montant",
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
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: "Description",
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.0),
          borderSide: const BorderSide(),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      ),
      maxLines: 3,
    );
  }

  Widget _buildRightColumn() {
    return Card(
      color: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildButton(
              context: context,
              onPressed: () => setState(() {
                selectedButton = "Dépense Standard";
                _view = _buildLeftColumn();
              }),
              libelle: "Dépense Standard",
              icon: Icons.attach_money,
            ),
            SizedBox(height: 8.0),
            buildMenuWithPermission(
              'voir approvisionnements',
              _buildButton(
                context: context,
                onPressed: () => setState(() {
                  selectedButton = "Approvisionnement";
                  _view = ApprovisionSaver();
                }),
                libelle: "Approvisionnement",
                icon: Icons.shopping_cart,
              ),
            ),
            SizedBox(height: 16.0),
            Divider(),
            SizedBox(height: 16.0),
            buildMenuWithPermission(
              'voir depenses',
              _buildButton(
                context: context,
                onPressed: () => setState(() {
                  selectedButton = "Consulter les dépenses standards";
                  _view = DepenseTable(
                    switchView: (Widget w) {
                      setState(() {
                        _view = w;
                      });
                    },
                  );
                }),
                libelle: "Consulter les dépenses standards",
                icon: Icons.attach_money,
              ),
            ),
            SizedBox(height: 8.0),
            buildMenuWithPermission(
              'voir approvisionnements',
              _buildButton(
                context: context,
                onPressed: () => setState(() {
                  selectedButton = "Consulter les approvisionnements";
                  _view = ApprovisionTable(
                    switchView: (Widget w) {
                      setState(() {
                        _view = w;
                      });
                    },
                  );
                }),
                libelle: "Consulter les approvisionnement",
                icon: Icons.shopping_cart,
              ),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildButton(
          context: context,
          onPressed: () async {
            await _pickFile();
          },
          libelle: "Ajouter Fichier",
          icon: Icons.add_link_outlined,
          width: 200,
          color: const Color.fromARGB(255, 5, 202, 133),
        ),
        SizedBox(height: 16.0),
        if (fichiers.isNotEmpty)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: fichiers.map((f) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f.path.split('\\').last,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.close, size: 18, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          fichiers.remove(f);
                        });
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String libelle,
    required IconData icon,
    required VoidCallback onPressed,
    double? width,
    Color? color,
  }) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        bool isSelected = selectedButton == libelle;

        return SizedBox(
          height: 40,
          width: width ?? double.infinity,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: isSelected
                  ? const Color.fromARGB(255, 5, 202, 133).withOpacity(0.6)
                  : color ?? themeProvider.themeData.colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0)),
            ),
            onPressed: onPressed,
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
