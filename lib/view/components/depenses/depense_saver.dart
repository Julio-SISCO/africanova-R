// ✅ Optimisation complète du widget DepenseSaver avec mise à jour fiable de la date sélectionnée

import 'dart:io';
import 'package:africanova/controller/depense_controller.dart';
import 'package:africanova/database/categorie_depense.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/util/date_formatter.dart';
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
  final categories =
      Hive.box<CategorieDepense>('categorieDepenseBox').values.toList();
  final _montantController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _designationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<File> fichiers = [];
  DateTime _selectedDate = DateTime.now();
  String categorieError = '';
  bool isLoading = false;
  late Widget _view;

  @override
  void initState() {
    super.initState();
    _view = _buildLeftColumn();
  }

  void _submitForm(String status) async {
    if (_formKey.currentState!.validate() &&
        _selectedCategorieDepense != null) {
      setState(() => isLoading = true);

      final result = await storeDepense(
        montant: double.parse(_montantController.text),
        date: _selectedDate,
        status: status,
        designation: _designationController.text,
        description: _descriptionController.text,
        categorie: _selectedCategorieDepense?.id ?? 0,
        fichiers: fichiers,
      );

      Get.snackbar('', result["message"],
          titleText: const SizedBox.shrink(),
          messageText: Center(child: Text(result["message"])),
          maxWidth: 300,
          snackPosition: SnackPosition.BOTTOM);

      if (result['status'] == true) {
        _formKey.currentState!.reset();
        _montantController.clear();
        _descriptionController.clear();
        fichiers.clear();
        _selectedCategorieDepense = null;
        _selectedDate = DateTime.now();
      }

      setState(() => isLoading = false);
    } else if (_selectedCategorieDepense == null) {
      setState(() => categorieError = 'Veuillez choisir une catégorie');
    }
  }

  Widget _buildLeftColumn() => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        elevation: 0,
        color: Colors.grey.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  _buildButton(
                    "Enregistrer",
                    Icons.save,
                    () => _submitForm('en_attente'),
                    color: const Color(0xFF05CA85).withOpacity(0.6),
                    width: 150,
                  ),
                  const SizedBox(width: 8),
                  _buildButton(
                      "Valider", Icons.done, () => _submitForm('valide'),
                      color: const Color(0xFF05CA85), width: 150),
                ],
              ),
              const SizedBox(height: 32),
              _buildForm(),
            ],
          ),
        ),
      );

  Widget _buildForm() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildCategoryDropdown()),
                      Expanded(
                          child: buildDatePicker(
                        initialDate: _selectedDate,
                        onDateChanged: (newDate) {
                          setState(() {
                            _selectedDate = newDate;
                          });
                        },
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildMontantField()),
                      Expanded(
                        child: _buildDescriptionField(
                          'Deignation',
                          null,
                          _designationController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDescriptionField(
                    'Description',
                    3,
                    _descriptionController,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildFilePicker(),
            ),
          ),
        ],
      );

  Widget _buildCategoryDropdown() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDropdown<CategorieDepense>(
            "Catégorie de dépenses",
            categories,
            _selectedCategorieDepense,
            Colors.grey.withOpacity(0.1),
            false,
            (value) => setState(() {
              categorieError = '';
              _selectedCategorieDepense = value;
            }),
          ),
          if (categorieError.isNotEmpty)
            Text(categorieError, style: TextStyle(color: Colors.red[500])),
        ],
      );

  Widget _buildMontantField() => TextFormField(
        controller: _montantController,
        decoration: _inputDecoration("Montant"),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez entrer un montant';
          }
          if (num.tryParse(value) == null) {
            return 'Veuillez entrer un montant valide';
          }
          return null;
        },
      );

  Widget _buildDescriptionField(
          String label, int? maxLine, TextEditingController controller) =>
      TextFormField(
        controller: controller,
        decoration: _inputDecoration(label),
        maxLines: maxLine ?? 1,
      );

  Widget _buildFilePicker() {
    return StatefulBuilder(builder: (context, setLocalState) {
      List<File> fichiers = this.fichiers;
      return Column(
        children: [
          _buildButton(
            "Ajouter Fichier",
            Icons.add_link_outlined,
            () async {
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
                  this.fichiers.addAll(result.paths.map((path) => File(path!)));
                });
                setLocalState(() {
                  fichiers = this.fichiers;
                });
              }
            },
            width: 200,
            color: const Color(0xFF05CA85),
          ),
          const SizedBox(height: 16),
          ...fichiers.map(
            (f) => Row(
              children: [
                const Icon(Icons.insert_drive_file,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    f.path.split(Platform.pathSeparator).last,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                  onPressed: () {
                    setState(() => this.fichiers.remove(f));
                    setLocalState(() => fichiers = this.fichiers);
                  },
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildRightColumn() => Card(
        color: Colors.grey.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildButton("Dépense Standard", Icons.attach_money, () {
                setState(() {
                  selectedButton = "Dépense Standard";
                  _view = _buildLeftColumn();
                });
              }),
              const SizedBox(height: 8),
              buildMenuWithPermission(
                'voir approvisionnements',
                _buildButton("Approvisionnement", Icons.shopping_cart, () {
                  setState(() {
                    selectedButton = "Approvisionnement";
                    _view = const ApprovisionSaver();
                  });
                }),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              buildMenuWithPermission(
                'voir depenses',
                _buildButton(
                    "Consulter les dépenses standards", Icons.attach_money, () {
                  setState(() {
                    selectedButton = "Consulter les dépenses standards";
                    _view = DepenseTable(
                        switchView: (w) => setState(() => _view = w));
                  });
                }),
              ),
              const SizedBox(height: 8),
              buildMenuWithPermission(
                'voir approvisionnements',
                _buildButton(
                    "Consulter les approvisionnements", Icons.shopping_cart,
                    () {
                  setState(() {
                    selectedButton = "Consulter les approvisionnements";
                    _view = ApprovisionTable(
                        switchView: (w) => setState(() => _view = w));
                  });
                }),
              ),
            ],
          ),
        ),
      );

  Widget _buildButton(String label, IconData icon, VoidCallback onPressed,
      {double? width, Color? color}) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isSelected = selectedButton == label;
        return SizedBox(
          height: 40,
          width: width,
          child: TextButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white, size: 18),
            label: Text(label, style: const TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: isSelected
                  ? const Color(0xFF05CA85).withOpacity(0.6)
                  : color ?? themeProvider.themeData.colorScheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        labelText: label,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _view),
              Expanded(flex: 2, child: _buildRightColumn()),
            ],
          ),
        ),
      ),
    );
  }
}
