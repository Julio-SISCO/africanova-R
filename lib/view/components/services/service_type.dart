// ignore_for_file: deprecated_member_use

import 'package:africanova/controller/service_controller.dart';
import 'package:africanova/database/type_article.dart';
import 'package:africanova/database/type_outil.dart';
import 'package:africanova/database/type_service.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/services/service_type_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ServiceType extends StatefulWidget {
  final Function(Widget content) changeContent;
  final Function(Widget) switchView;
  final TypeService typeService;
  final VoidCallback? refresh;
  const ServiceType({
    super.key,
    required this.changeContent,
    required this.typeService,
    this.refresh,
    required this.switchView,
  });

  @override
  State<ServiceType> createState() => _ServiceTypeState();
}

class _ServiceTypeState extends State<ServiceType> {
  void _delete(int id) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content:
              const Text('Êtes-vous sûr de vouloir supprimer cet element ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final result = await deleteTypeService(id);

      if (result['status']) {
        widget.changeContent(
          ServiceTypeForm(
            serviceType: widget.typeService,
            switchView: (Widget w) => widget.switchView(w),
            changeContent: (Widget content) => widget.changeContent,
          ),
        );
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
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
            ),
            elevation: 4.0,
            color: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .primary,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.typeService.libelle.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        children: [
                          buildMenuWithPermission(
                            'modifier type de services',
                            Tooltip(
                              message: "Modifier cet élément",
                              child: IconButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey.withOpacity(0.1),
                                ),
                                onPressed: () {
                                  widget.changeContent(
                                    ServiceTypeForm(
                                      switchView: (Widget w) =>
                                          widget.switchView(w),
                                      serviceType: widget.typeService,
                                      changeContent: (Widget content) =>
                                          widget.changeContent(content),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.edit,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          buildMenuWithPermission(
                            'supprimer type de services',
                            Tooltip(
                              message: "Supprimer cet élément",
                              child: IconButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                ),
                                onPressed: () {
                                  _delete(widget.typeService.id);
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (widget.typeService.description != null)
                    Padding(
                      padding: EdgeInsets.only(left: 32.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * .7,
                        child: Text(
                          widget.typeService.description ?? '',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 16.0),
                  ((widget.typeService.outilTypeList == null ||
                              widget.typeService.outilTypeList!.isEmpty) &&
                          (widget.typeService.articleTypeList == null ||
                              widget.typeService.articleTypeList!.isEmpty))
                      ? Center(
                          child: Text(
                            'Aucun outil ou article associé.',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          alignment: WrapAlignment.start,
                          children: [
                            ...List.generate(
                              widget.typeService.outilTypeList!.length,
                              (index) => _buildOutilCard(
                                outil: widget.typeService.outilTypeList![index],
                              ),
                            ),
                            ...List.generate(
                              widget.typeService.articleTypeList!.length,
                              (index) => _buildOutilCard(
                                article:
                                    widget.typeService.articleTypeList![index],
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutilCard({TypeOutil? outil, TypeArticle? article}) {
    if (outil != null) {
      return SizedBox(
        width: 200.0,
        height: 120.0,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          elevation: 0,
          margin: EdgeInsets.all(0.0),
          color: Colors.blueGrey[200],
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 20.0, top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tooltip(
                  message: outil.outil.libelle,
                  child: Text(
                    outil.outil.libelle,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Tooltip(
                  message: outil.outil.description ?? "",
                  child: Text(
                    outil.outil.description ?? "",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  elevation: 0,
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Tarif à l'unité (${outil.tarifUsager?.toStringAsFixed(0) ?? 0}F)",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (article != null) {
      return SizedBox(
        width: 200.0,
        height: 120.0,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          elevation: 0,
          margin: EdgeInsets.all(0.0),
          color: Colors.blueGrey[200],
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 20.0, top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tooltip(
                  message: article.article.libelle,
                  child: Text(
                    article.article.libelle ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Tooltip(
                  message: article.article.description ?? "",
                  child: Text(
                    article.article.description ?? "",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  elevation: 0,
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Tarif à l'unité (${article.tarifUsager?.toStringAsFixed(0) ?? 0}F)",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Container();
  }
}
