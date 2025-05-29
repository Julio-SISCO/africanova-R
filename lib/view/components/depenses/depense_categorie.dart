import 'package:africanova/controller/categorie_depense_controller.dart';
import 'package:africanova/database/categorie_depense.dart';
import 'package:africanova/database/my_icon.dart';
import 'package:africanova/database/type_depense.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/widget/dialogs.dart';
import 'package:africanova/widget/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class DepenseCategorie extends StatefulWidget {
  const DepenseCategorie({super.key});

  @override
  State<DepenseCategorie> createState() => _DepenseCategorieState();
}

class _DepenseCategorieState extends State<DepenseCategorie> {
  final TextEditingController _libelleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  CategorieDepense? _selectedCategorieDepense;
  TypeDepense? _selectedTypeDepense;
  MyIcon? _selectedIcon;
  List<TypeDepense> typeDepenses = [];
  bool isLoading = false;
  List<MyIcon> iconsList = [];
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    typeDepenses = Hive.box<TypeDepense>('typeDepenseBox').values.toList();
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    var box = Hive.box<MyIcon>('iconBox');
    setState(() {
      iconsList = box.values.toList();
    });
  }

  // Reste des fonctions inchangées...
  Future<void> _ajouterOuModifierCategorieDepense() async {
    if (_formKey.currentState!.validate() && _selectedTypeDepense != null) {
      setState(() => isLoading = true);

      final categorieDepense = CategorieDepense(
        nom: _libelleController.text,
        description: _descriptionController.text,
        typeDepense: _selectedTypeDepense,
        icon: _selectedIcon,
      );

      Map<String, dynamic> result;
      if (_selectedCategorieDepense == null) {
        result = await sendCategorieDepense(categorieDepense: categorieDepense);
      } else {
        result = await updateCategorieDepense(
          categorieDepense: categorieDepense,
          id: _selectedCategorieDepense!.id ?? 0,
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

  void _modifierCategorieDepense(CategorieDepense categorie) {
    setState(() {
      _selectedCategorieDepense = categorie;
      _libelleController.text = categorie.nom;
      _descriptionController.text = categorie.description ?? '';
      _selectedIcon = categorie.icon;
      _selectedTypeDepense = categorie.typeDepense;
    });
  }

  void _resetForm() {
    setState(() {
      _selectedCategorieDepense = null;
      _libelleController.clear();
      _descriptionController.clear();
      _searchController.clear();
      _selectedIcon = null;
    });
  }

  void _cancel(context, int id) async {
    final result = await deleteCategorieDepense(id);
    if (result['status']) {
      Get.back();
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
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Categories de Dépenses",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Expanded(
                      child: ValueListenableBuilder<Box<CategorieDepense>>(
                        valueListenable:
                            Hive.box<CategorieDepense>('categorieDepenseBox')
                                .listenable(),
                        builder: (context, box, _) {
                          final categoriesDepense = box.values.toList();
                          return SingleChildScrollView(
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: categoriesDepense.map((categorie) {
                                return InkWell(
                                  onTap: () =>
                                      _modifierCategorieDepense(categorie),
                                  mouseCursor: SystemMouseCursors.click,
                                  child: SizedBox(
                                    width: 400.0,
                                    height: 120.0,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      child: ListTile(
                                        tileColor: Colors.grey.withOpacity(0.1),
                                        title: Wrap(
                                          spacing: 8.0,
                                          children: [
                                            if (categorie.icon != null)
                                              SvgPicture.asset(
                                                'assets/icons/${categorie.icon!.nom}',
                                                height: 20.0,
                                                width: 20.0,
                                                color:
                                                    Provider.of<ThemeProvider>(
                                                            context)
                                                        .themeData
                                                        .colorScheme
                                                        .tertiary,
                                              ),
                                            if (categorie.icon == null)
                                              Icon(Icons.wallet),
                                            Text(
                                              categorie.nom,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 24.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                categorie.typeDepense?.nom ??
                                                    '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 210, 2, 106),
                                                ),
                                              ),
                                              Text(
                                                categorie.description ?? '',
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 11.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                        trailing: IconButton(
                                          onPressed: () {
                                            showCancelConfirmationDialog(
                                              context,
                                              () {
                                                _cancel(
                                                    context, categorie.id ?? 0);
                                              },
                                              'Êtes-vous sûr de vouloir annuler cette categorie de dépense ?',
                                            );
                                            setState(() {
                                              if (_selectedCategorieDepense ==
                                                  categorie) {
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
                borderRadius: BorderRadius.circular(4.0),
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
                        cursorColor: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .tertiary,
                        decoration: InputDecoration(
                          labelText: 'Libellé',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Le libellé est requis.'
                            : null,
                      ),
                      const SizedBox(height: 16.0),
                      buildDropdown<TypeDepense>(
                        "Type de dépenses",
                        typeDepenses,
                        _selectedTypeDepense,
                        Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .surface,
                        false,
                        (value) {
                          setState(() {
                            _selectedTypeDepense = value;
                          });
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
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16.0),
                      Text('Sélectionnez une icône'),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Rechercher...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        color: Colors.grey.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 4.0,
                        ),
                        height: 225.0,
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 16.0,
                            runSpacing: 16.0,
                            children: iconsList
                                .where((icon) => icon.libelle
                                    .toLowerCase()
                                    .contains(searchQuery))
                                .map((icon) {
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  return SizedBox(
                                    width: constraints.maxWidth / 6,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedIcon = icon;
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/${icon.nom}',
                                            height: 20.0,
                                            width: 20.0,
                                            color: _selectedIcon == icon
                                                ? Colors.blue
                                                : Provider.of<ThemeProvider>(
                                                        context)
                                                    .themeData
                                                    .colorScheme
                                                    .tertiary,
                                          ),
                                          Text(
                                            icon.libelle.split('-').first,
                                            style: TextStyle(
                                              fontSize: 10.0,
                                              color: _selectedIcon == icon
                                                  ? Colors.blue
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : _ajouterOuModifierCategorieDepense,
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 5, 202, 133),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
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
                                      _selectedCategorieDepense == null
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
                          if (_selectedCategorieDepense != null)
                            Expanded(
                              child: TextButton(
                                onPressed: _resetForm,
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0),
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
