import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class UpgradeVersion extends StatelessWidget {
  final String version;
  const UpgradeVersion({super.key, required this.version});

  Future<void> _launchURL(BuildContext context) async {
    final String url = 'https://africanova-in-640718.hostingersite.com';
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      await Hive.deleteFromDisk();
    } else {
      Get.snackbar(
        '',
        'Impossible d\'ouvrir l\'URL : $url',
        titleText: SizedBox.shrink(),
        messageText: Center(
          child: Text('Impossible d\'ouvrir l\'URL : $url'),
        ),
        maxWidth: 300,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Nouvelle version disponible',
              style: TextStyle(fontSize: 30.0),
            ),
            SizedBox(height: 20.0),
            Text.rich(
              TextSpan(
                text: 'Passez maintenant à la version ',
                children: [
                  TextSpan(
                    text: version,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: ' pour continuer !',
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: () => _launchURL(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: Text('Télécharger'),
            ),
          ],
        ),
      ),
    );
  }
}
