import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> getDir(String path) async {
  String newPath = "";
  final directory = await getApplicationDocumentsDirectory();

  final dir = Directory("${directory.path}/Africa Nova/$path");

  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  newPath = dir.path;
  return newPath;
}

void openFile(String filePath) {
  if (Platform.isWindows) {
    Process.run("explorer", [filePath]);
  } else if (Platform.isMacOS) {
    Process.run("open", [filePath]);
  } else if (Platform.isLinux) {
    Process.run("xdg-open", [filePath]);
  }
}
