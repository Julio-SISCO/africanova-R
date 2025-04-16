import 'package:africanova/controller/service_controller.dart';
import 'package:africanova/database/outil.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/widget/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ServiceOutilCard extends StatefulWidget {
  final Outil outil;
  
  const ServiceOutilCard({
    super.key,
    required this.outil,
  });

  @override
  State<ServiceOutilCard> createState() => _ServiceOutilCardState();
}

class _ServiceOutilCardState extends State<ServiceOutilCard> {
  void _delete(int id) async {
    final result = await deleteOutil(id);
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
      width: 300.0,
      height: 100.0,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        elevation: 0,
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 8.0),
          title: Tooltip(
            message: widget.outil.libelle,
            child: Row(
              spacing: 4.0,
              children: [
                SvgPicture.asset(
                  'assets/icons/34.svg',
                  height: 18.0,
                  width: 18.0,
                  color: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .tertiary,
                ),
                Text(
                  widget.outil.libelle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          subtitle: Tooltip(
            message: widget.outil.description ?? "",
            child: Text(
              widget.outil.description ?? "",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          trailing: buildMenuWithPermission(
            'supprimer outils',
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () {
                showCancelConfirmationDialog(
                  context,
                  () {
                    _delete(widget.outil.id);
                  },
                  'Êtes-vous sûr de vouloir supprimer cet outil ?',
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
