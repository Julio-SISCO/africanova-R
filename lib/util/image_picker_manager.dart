import 'dart:convert';
import 'dart:io';

import 'package:africanova/static/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

Future<File?> getImageFromGallery(ImagePicker picker) async {
  XFile? imagePicked = await picker.pickImage(source: ImageSource.gallery);
  if (imagePicked != null) {
    File? croppedFile = await cropImage(File(imagePicked.path));
    if (croppedFile != null) {
      return croppedFile;
    }
  }
  return null;
}

Future<File?> cropImage(File pickedFile) async {
  final croppedImagePath = await Get.to(ImageCropPage(file: pickedFile));

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
    final imageBytes = await file.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image != null) {
      final aspectRatio = 4 / 3;
      int cropWidth, cropHeight;

      if (image.width / image.height > aspectRatio) {
        cropHeight = image.height;
        cropWidth = (cropHeight * aspectRatio).toInt();
      } else {
        cropWidth = image.width;
        cropHeight = (cropWidth / aspectRatio).toInt();
      }

      final x = (image.width - cropWidth) ~/ 2;
      final y = (image.height - cropHeight) ~/ 2;

      final croppedImage = img.copyCrop(
        image,
        x: x,
        y: y,
        width: cropWidth,
        height: cropHeight,
      );

      final tempDir =
          await getTemporaryDirectory();
      final croppedFile = File(
          '${tempDir.path}/cropped_image_${DateTime.now().millisecondsSinceEpoch}.png');
      croppedFile.writeAsBytesSync(img.encodePng(croppedImage));

      Get.back(result: croppedFile.path);
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
                child: TextButton(
                  style: TextButton.styleFrom(
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
