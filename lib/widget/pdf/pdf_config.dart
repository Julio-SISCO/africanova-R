import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';

Future<Uint8List> convertSvgToPng(String assetPath) async {
  final PictureInfo pictureInfo = await vg.loadPicture(
    SvgAssetLoader(assetPath),
    null,
  );

  final ui.Image image = await pictureInfo.picture.toImage(200, 180);
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
