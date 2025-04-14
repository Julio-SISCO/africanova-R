import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<void> printDoc({
  required String nomDoc,
  required String path,
  required Future<Uint8List> Function() generatePDF,
}) async {
  try {
    // Générer le fichier PDF
    final pdfFile = await generatePDF();

    // Obtenir le chemin du répertoire
    final dirPath = await getDir(path);

    // Construire le chemin complet du fichier
    final filePath = "$dirPath/$nomDoc.pdf";
    final file = File(filePath);

    // Créer le fichier s'il n'existe pas
    if (!await file.exists()) {
      await file.create(recursive: true);
    }

    // Écrire les données PDF dans le fichier
    await file.writeAsBytes(pdfFile);

    // Ouvrir le fichier
    openFile(filePath);
  } catch (e) {
    debugPrint("Erreur lors de la génération ou de l'ouverture du PDF : $e");
  }
}

Future<String> getDir(String path) async {
  try {
    // Obtenir le répertoire des documents de l'application
    final directory = await getApplicationDocumentsDirectory();

    // Construire le chemin du sous-dossier
    final dir = Directory("${directory.path}/Africa Nova/$path");

    // Créer le répertoire s'il n'existe pas
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return dir.path;
  } catch (e) {
    debugPrint("Erreur lors de la création du répertoire : $e");
    rethrow;
  }
}

void openFile(String filePath) {
  try {
    if (Platform.isWindows) {
      Process.run("explorer", [filePath]);
    } else if (Platform.isMacOS) {
      Process.run("open", [filePath]);
    } else if (Platform.isLinux) {
      Process.run("xdg-open", [filePath]);
    } else {
      debugPrint("Plateforme non prise en charge pour ouvrir le fichier.");
    }
  } catch (e) {
    debugPrint("Erreur lors de l'ouverture du fichier : $e");
  }
}
