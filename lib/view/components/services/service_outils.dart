import 'package:africanova/controller/service_controller.dart';
import 'package:africanova/database/outil.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/services/service_outil_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class ServiceOutil extends StatefulWidget {
  const ServiceOutil({super.key});

  @override
  State<ServiceOutil> createState() => _ServiceOutilState();
}

class _ServiceOutilState extends State<ServiceOutil> {
  bool _showForm = false;
  Outil? _outil;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _libelleController;
  late TextEditingController _descriptionController;

  bool _isLoading = false;

  @override
  void dispose() {
    _libelleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _outil = null;
      _formKey.currentState!.reset();
      _libelleController.clear();
      _descriptionController.clear();
      _isLoading = false;
    });
  }

  void _saveOutil() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final newService = Outil(
        id: 0,
        libelle: _libelleController.text,
        description: _descriptionController.text,
      );
      Map<String, dynamic> result = {};
      if (_outil != null) {
        result = await updateOutil(newService, (_outil?.id ?? 0));
      } else {
        result = await sendOutil(newService);
      }
      if (result['status']) {
        _resetForm();
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

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setEditableOutil(Outil outil) {
    setState(() {
      _showForm = false;
      _outil = outil;
      _libelleController = TextEditingController(text: _outil?.libelle ?? '');
      _descriptionController =
          TextEditingController(text: _outil?.description ?? '');
      _showForm = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Outil>>(
      valueListenable: Hive.box<Outil>("outilBox").listenable(),
      builder: (context, box, _) {
        final outils = box.values.toList();
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          elevation: 0.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  elevation: 0.0,
                  color: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .primary,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          buildMenuWithPermission(
                            'enregistrer outils',
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor:
                                      Provider.of<ThemeProvider>(context)
                                          .themeData
                                          .colorScheme
                                          .secondary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.0),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _outil = null;
                                    _showForm = true;
                                  });
                                },
                                label: Text('Ajouter'),
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Wrap(
                            children: [
                              ...List.generate(
                                outils.length,
                                (index) => InkWell(
                                  onTap: () async {
                                    final perm =
                                        await hasPermission('modifier outils');
                                    if (perm) {
                                      _setEditableOutil(outils[index]);
                                    }
                                  },
                                  child: ServiceOutilCard(outil: outils[index]),
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
              if (_showForm)
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                        elevation: 0.0,
                        color: Provider.of<ThemeProvider>(context)
                            .themeData
                            .colorScheme
                            .primary,
                        child: _buildForm(),
                      ),
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: CircleAvatar(
                          backgroundColor: Colors.blueGrey,
                          radius: 12,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.cancel_outlined,
                                size: 16, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _showForm = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForm() {
    return Padding(
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
              cursorColor: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .tertiary,
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
                    onPressed: _isLoading ? null : _saveOutil,
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 5, 202, 133),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    icon: _isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Provider.of<ThemeProvider>(context)
                                    .themeData
                                    .colorScheme
                                    .secondary,
                                strokeWidth: 2),
                          )
                        : const Icon(Icons.save, color: Colors.white),
                    label: _isLoading
                        ? const SizedBox.shrink()
                        : const Text(
                            "Enregistrer",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                if (_outil != null)
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
    );
  }
}
