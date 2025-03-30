import 'package:africanova/controller/service_controller.dart';
import 'package:africanova/database/outil.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/services/service_outil_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class ServiceOutil extends StatefulWidget {
  const ServiceOutil({super.key});

  @override
  State<ServiceOutil> createState() => _ServiceOutilState();
}

class _ServiceOutilState extends State<ServiceOutil> {
  List<Outil> _outils = [];
  bool _showForm = false;
  Outil? _outil;

  @override
  void initState() {
    super.initState();
    _outils = Hive.box<Outil>('outilBox').values.toList();
  }

  void _refresh() {
    setState(() {
      _showForm = false;
      _outils = Hive.box<Outil>('outilBox').values.toList();
    });
  }

  void _setEditableOutil(Outil outil) {
    setState(() {
      _showForm = false;
      _outil = outil;
      _showForm = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      elevation: 0.0,
      child: Row(
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
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildMenuWithPermission(
                        'enregistrer outils',
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              elevation: 0.0,
                              foregroundColor:
                                  Provider.of<ThemeProvider>(context)
                                      .themeData
                                      .colorScheme
                                      .tertiary,
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
                              color: Provider.of<ThemeProvider>(context)
                                  .themeData
                                  .colorScheme
                                  .tertiary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.start,
                        children: [
                          ...List.generate(
                            _outils.length,
                            (index) => ServiceOutilCard(
                              outil: _outils[index],
                              setEditableOutil: (Outil outil) =>
                                  _setEditableOutil(outil),
                              refresh: _refresh,
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
                    child: OutilForm(
                      refresh: _refresh,
                      outil: _outil,
                    ),
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
  }
}

class OutilForm extends StatefulWidget {
  final VoidCallback refresh;
  final Outil? outil;
  const OutilForm({super.key, required this.refresh, this.outil});

  @override
  State<OutilForm> createState() => _OutilFormState();
}

class _OutilFormState extends State<OutilForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _libelleController;
  late TextEditingController _descriptionController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _libelleController =
        TextEditingController(text: widget.outil?.libelle ?? '');
    _descriptionController =
        TextEditingController(text: widget.outil?.description ?? '');
  }

  @override
  void dispose() {
    _libelleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
      if (widget.outil != null) {
        result = await updateOutil(newService, (widget.outil?.id ?? 0));
      } else {
        result = await sendOutil(newService);
      }
      if (result['status']) {
        setState(() {
          _formKey.currentState!.reset();
          _libelleController.clear();
          _descriptionController.clear();
          _isLoading = false;
        });
        widget.refresh();

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

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
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
                const SizedBox(height: 24.0),
                SizedBox(
                  height: 40.0,
                  width: MediaQuery.of(context).size.width / 3,
                  child: TextButton.icon(
                    onPressed: _isLoading ? null : _saveOutil,
                    style: TextButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.blueGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    icon: const Icon(
                      Icons.save,
                      color: Colors.white,
                    ),
                    label: const Text(
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
              ],
            ),
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
}
