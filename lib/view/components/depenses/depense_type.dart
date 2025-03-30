import 'package:africanova/controller/type_depense_controller.dart';
import 'package:africanova/database/type_depense.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/widget/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class DepenseType extends StatefulWidget {
  const DepenseType({super.key});

  @override
  State<DepenseType> createState() => _DepenseTypeState();
}

class _DepenseTypeState extends State<DepenseType> {
  final TextEditingController _libelleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  TypeDepense? _selectedTypeDepense;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _ajouterOuModifierTypeDepense() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      final typeDepense = TypeDepense(
        nom: _libelleController.text,
        description: _descriptionController.text,
        categories: 0,
      );

      Map<String, dynamic> result;
      if (_selectedTypeDepense == null) {
        result = await sendTypeDepense(typeDepense: typeDepense);
      } else {
        result = await updateTypeDepense(
          typeDepense: typeDepense,
          id: _selectedTypeDepense!.id ?? 0,
        );
      }

      if (result['status'] == true) {
        _resetForm();
      }

      Get.snackbar(
        '',
        result["message"],
        titleText: const SizedBox.shrink(),
        messageText: Center(child: Text(result["message"])),
        maxWidth: 300,
        snackPosition: SnackPosition.BOTTOM,
      );

      setState(() => isLoading = false);
    }
  }

  void _modifierTypeDepense(TypeDepense type) {
    setState(() {
      _selectedTypeDepense = type;
      _libelleController.text = type.nom;
      _descriptionController.text = type.description ?? '';
    });
  }

  void _resetForm() {
    setState(() {
      _selectedTypeDepense = null;
      _libelleController.clear();
      _descriptionController.clear();
    });
  }

  void _cancel(context, int id) async {
    final result = await deleteTypeDepense(id);
    if (result['status']) {
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).themeData;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Types de Dépenses",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Expanded(
                      child: ValueListenableBuilder<Box<TypeDepense>>(
                        valueListenable: Hive.box<TypeDepense>('typeDepenseBox')
                            .listenable(),
                        builder: (context, box, _) {
                          final typesDepense = box.values.toList();
                          return SingleChildScrollView(
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: typesDepense.map((type) {
                                return InkWell(
                                  onTap: () => _modifierTypeDepense(type),
                                  mouseCursor: SystemMouseCursors.click,
                                  child: SizedBox(
                                    width: 400.0,
                                    height: 120.0,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(2.0),
                                      ),
                                      elevation: 0.0,
                                      child: ListTile(
                                        tileColor: Colors.grey.withOpacity(0.1),
                                        title: Text(
                                          type.nom,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              type.description ?? '',
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 11.0),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8.0),
                                              child: Wrap(
                                                spacing: 2.0,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  Text(
                                                    "${type.categories} categories",
                                                    style: const TextStyle(
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255, 210, 2, 106),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {},
                                                    child: Icon(
                                                      Icons.open_in_new,
                                                      size: 12.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: IconButton(
                                          onPressed: () {
                                            showCancelConfirmationDialog(
                                              context,
                                              () {
                                                _cancel(context, type.id ?? 0);
                                              },
                                              'Êtes-vous sûr de vouloir annuler ce type de dépense ?',
                                            );
                                            setState(() {
                                              if (_selectedTypeDepense ==
                                                  type) {
                                                _resetForm();
                                              }
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _libelleController,
                        cursorColor: theme.colorScheme.tertiary,
                        decoration: InputDecoration(
                          labelText: 'Libellé',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Le libellé est requis.'
                            : null,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _descriptionController,
                        cursorColor: theme.colorScheme.tertiary,
                        decoration: InputDecoration(
                          labelText: 'Description (optionnelle)',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : _ajouterOuModifierTypeDepense,
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 5, 202, 133),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                              ),
                              icon: isLoading
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          color: Provider.of<ThemeProvider>(
                                                  context)
                                              .themeData
                                              .colorScheme
                                              .secondary,
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save, color: Colors.white),
                              label: isLoading
                                  ? const SizedBox.shrink()
                                  : Text(
                                      _selectedTypeDepense == null
                                          ? "Enregistrer"
                                          : "Modifier",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (_selectedTypeDepense != null)
                            Expanded(
                              child: TextButton(
                                onPressed: _resetForm,
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                ),
                                child: const Text(
                                  "Annuler",
                                  style: TextStyle(color: Colors.white),
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
        ],
      ),
    );
  }
}
