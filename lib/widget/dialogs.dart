// ignore_for_file: use_build_context_synchronously

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
              style: ElevatedButton.styleFrom(
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
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
