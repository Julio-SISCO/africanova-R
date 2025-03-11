import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Future<void> windowConfig() async {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1300, 800),
    minimumSize: Size(1300, 800),
    center: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
