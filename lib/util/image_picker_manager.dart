// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:africanova/static/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

Future<List<String>> convertFilesToBytes(List<File> files) async {
  List<String> bytesList = [];
  for (var file in files) {
    List<int> bytes = await file.readAsBytes();
    String base64Image = base64Encode(bytes);
    bytesList.add(base64Image);
  }
  return bytesList;
}

Future<List<String>?> saveImagesLocally(List<File> images) async {
  List<String> imagePaths = [];
  try {
    for (int i = 0; i < images.length; i++) {
      final imageFile = images[i];
      final directory = await getApplicationDocumentsDirectory();
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      String filePath = '${directory.path}/$fileName';
      await imageFile.copy(filePath);
      imagePaths.add(filePath);
    }
    return imagePaths;
  } catch (e) {
    debugPrint('Erreur lors de la sauvegarde des images : $e');
    return [];
  }
}

Future<File?> getImageFromGallery(
    ImagePicker picker, BuildContext context) async {
  XFile? imagePicked = await picker.pickImage(source: ImageSource.gallery);
  if (imagePicked != null) {
    File? croppedFile = await cropImage(File(imagePicked.path), context);
    if (croppedFile != null) {
      return croppedFile;
    }
  }
  return null;
}

Future<File?> cropImage(File pickedFile, BuildContext context) async {
  final croppedImagePath = await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ImageCropPage(file: pickedFile),
    ),
  );

  if (croppedImagePath != null) {
    return File(croppedImagePath);
  }

  return null;
}

class ImageCropPage extends StatefulWidget {
  final File file;
  const ImageCropPage({super.key, required this.file});

  @override
  State<ImageCropPage> createState() => _ImageCropPageState();
}

class _ImageCropPageState extends State<ImageCropPage> {
  Future<void> _cropImage(File file) async {
    // Charger l'image
    final imageBytes = await file.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image != null) {
      // Calculer les dimensions du rectangle de recadrage respectant le ratio 4:3
      final aspectRatio = 4 / 3;
      int cropWidth, cropHeight;

      if (image.width / image.height > aspectRatio) {
        // L'image est plus large que le ratio 4:3
        cropHeight = image.height;
        cropWidth = (cropHeight * aspectRatio).toInt();
      } else {
        // L'image est plus haute ou égale au ratio 4:3
        cropWidth = image.width;
        cropHeight = (cropWidth / aspectRatio).toInt();
      }

      // Déterminer la position de départ du recadrage (centrée)
      final x = (image.width - cropWidth) ~/ 2;
      final y = (image.height - cropHeight) ~/ 2;

      // Recadrer l'image avec le ratio 4:3
      final croppedImage = img.copyCrop(
        image,
        x: x,
        y: y,
        width: cropWidth,
        height: cropHeight,
      );

      // Enregistrez l'image recadrée dans un fichier temporaire
      final tempDir =
          await getTemporaryDirectory(); // Utilisez le répertoire temporaire
      final croppedFile = File(
          '${tempDir.path}/cropped_image_${DateTime.now().millisecondsSinceEpoch}.png');
      croppedFile.writeAsBytesSync(img.encodePng(croppedImage));

      Navigator.of(context).pop(croppedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recadrage d\'Image'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16.0 * 2),
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                height: MediaQuery.of(context).size.width / 3,
                child: Image.file(widget.file),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                height: 16.0 * 2.5,
                width: 250,
                child: OutlinedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 2.0,
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: bgColor,
                    side: const BorderSide(
                      width: 2.0,
                      color: Colors.blueGrey,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text(
                    'Valider',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  onPressed: () async {
                    await _cropImage(widget.file);
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
