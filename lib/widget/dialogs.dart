// ignore_for_file: use_build_context_synchronously

import 'package:africanova/controller/article_controller.dart';
import 'package:africanova/database/article.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showCancelConfirmationDialog(
    BuildContext context, VoidCallback action, String message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('Confirmation'),
        backgroundColor:
            Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        content: Text(message),
        actions: <Widget>[
          SizedBox(
            width: 120.0,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .surface,
                foregroundColor: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .tertiary,
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Non',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .tertiary,
              foregroundColor: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .surface,
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            onPressed: action,
            child: Text(
              'Oui, continuer',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> showEditStockDialog(
  BuildContext context,
  Article article,
) async {
  final formKey = GlobalKey<FormState>();
  final TextEditingController stockController =
      TextEditingController(text: article.stock?.toString() ?? '0');
  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      final updatedStock = int.parse(stockController.text);
      final resultat = await updateStock(article.id!, updatedStock);

      if (resultat['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Modification enregistrée'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultat['message']),
          ),
        );
      }
    }
  }

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Modifier la quantité en stock'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: stockController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantité en stock',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer une quantité';
              }
              if (int.tryParse(value) == null) {
                return 'Veuillez entrer un nombre valide';
              }
              if (int.parse(value) < 0) {
                return 'La quantité ne peut pas être négative';
              }
              return null;
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Annuler'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Enregistrer'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await submit();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Modification enregistrée')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
