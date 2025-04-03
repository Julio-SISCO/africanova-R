import 'package:africanova/database/type_service.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/services/service_type_card.dart';
import 'package:africanova/view/components/services/service_type_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class ServiceSide extends StatefulWidget {
  final Function(Widget) switchView;
  final Function(Widget content) changeContent;
  final Function(bool) updateLoading;

  const ServiceSide({
    super.key,
    required this.changeContent,
    required this.updateLoading,
    required this.switchView,
  });

  @override
  State<ServiceSide> createState() => _ServiceSideState();
}

class _ServiceSideState extends State<ServiceSide> {
  bool toggled = false;
  late ValueListenable<Box<TypeService>> _typeServiceBoxListenable;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _typeServiceBoxListenable =
        Hive.box<TypeService>('typeServiceBox').listenable();
  }

  List<TypeService> _filterServices(Box<TypeService> box) {
    final services = box.values.toList();
    if (_searchQuery.isEmpty) {
      return services;
    }
    return services.where((type) {
      final searchLower = _searchQuery.toLowerCase();
      final libelleLower = type.libelle.toLowerCase();
      return libelleLower.contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        elevation: 0.0,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          elevation: 0.0,
          color:
              Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2.0),
                    topRight: Radius.circular(2.0),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            buildMenuWithPermission(
                              'enregistrer type de services',
                              IconButton(
                                icon: Icon(
                                  Icons.add_circle,
                                  color: Colors.blueGrey[800],
                                ),
                                onPressed: () {
                                  widget.changeContent(
                                    ServiceTypeForm(
                                      switchView: (Widget w) =>
                                          widget.switchView(w),
                                      changeContent: (Widget content) =>
                                          widget.changeContent(content),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: 76,
                              child: Text(
                                'Type Service'.toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          color: Colors.white,
                          icon: Icon(
                            Icons.screen_search_desktop_rounded,
                            color: Colors.blueGrey[800],
                          ),
                          onPressed: () {
                            setState(() {
                              toggled = !toggled;
                            });
                          },
                        ),
                      ],
                    ),
                    if (toggled) ...[
                      Divider(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                            labelText: 'Rechercher...',
                          ),
                          onChanged: (query) {
                            setState(() {
                              _searchQuery = query;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 4.0),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: ValueListenableBuilder<Box<TypeService>>(
                  valueListenable: _typeServiceBoxListenable,
                  builder: (context, box, _) {
                    final filteredServices = _filterServices(box);

                    if (filteredServices.isEmpty) {
                      return Center(
                        child: Text(
                          'Aucun type de service trouvé.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(
                          filteredServices.length,
                          (index) => ServiceTypeCard(
                            switchView: (Widget w) => widget.switchView(w),
                            type: filteredServices[index],
                            changeContent: (Widget content) =>
                                widget.changeContent(content),
                            refresh: () => setState(() {}),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
