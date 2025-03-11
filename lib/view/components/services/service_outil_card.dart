import 'package:africanova/controller/service_controller.dart';
import 'package:africanova/database/outil.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceOutilCard extends StatefulWidget {
  final VoidCallback refresh;
  final Outil outil;
  final bool shoBtn;
  final Function(Outil) setEditableOutil;
  const ServiceOutilCard({
    super.key,
    required this.outil,
    required this.setEditableOutil,
    required this.refresh,
    this.shoBtn = true,
  });

  @override
  State<ServiceOutilCard> createState() => _ServiceOutilCardState();
}

class _ServiceOutilCardState extends State<ServiceOutilCard> {
  void _delete(int id) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cet outil ?'),
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
      final result = await deleteOutil(id);

      if (result['status']) {
        widget.refresh();
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
    return Stack(
      children: [
        SizedBox(
          width: 200.0,
          height: 100.0,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            elevation: 0,
            margin: EdgeInsets.all(0.0),
            color: Colors.blueGrey[200],
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tooltip(
                    message: widget.outil.libelle,
                    child: Text(
                      widget.outil.libelle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Tooltip(
                    message: widget.outil.description ?? "",
                    child: Text(
                      widget.outil.description ?? "",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.shoBtn)
          Positioned(
            top: 4.0,
            right: 4.0,
            child: Column(
              children: [
                buildMenuWithPermission(
                  'modifier outils',
                  Tooltip(
                    message: "Modifier cet élément",
                    child: CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      radius: 12,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon:
                            Icon(Icons.settings, size: 16, color: Colors.white),
                        onPressed: () {
                          widget.setEditableOutil(widget.outil);
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4.0),
                buildMenuWithPermission(
                  'supprimer outils',
                  Tooltip(
                    message: "Supprimer cet élément",
                    child: CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      radius: 12,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.delete, size: 16, color: Colors.white),
                        onPressed: () {
                          _delete(widget.outil.id);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
