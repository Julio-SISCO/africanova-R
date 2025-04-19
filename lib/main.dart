import 'package:africanova/base.dart';
import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/controller/global_controller.dart';
import 'package:africanova/provider/database_provider.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/upgrade_version.dart';
import 'package:africanova/util/check_profil.dart';
import 'package:africanova/util/windows_manage.dart';
import 'package:africanova/view/auth/profile_form.dart';
import 'package:africanova/view/auth/auth_page.dart';
import 'package:africanova/view/auth/security_question_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await windowConfig();
  await DatabaseProvider.getDatabase();
  await DatabaseProvider.openBoxes();
  await clearHiveBoxes();
  await saveAppVersionData('1.1.9');

  bool isLoggedIn = await isUserLoggedIn();

  if (isLoggedIn) {
    startSessionCheck();
    await getGlobalData();
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
      ],
      home: StatusChecker(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}

class StatusChecker extends StatefulWidget {
  const StatusChecker({super.key});

  @override
  State<StatusChecker> createState() => _StatusCheckerState();
}

class _StatusCheckerState extends State<StatusChecker> {
  bool _safe = false;
  bool _isLoggedIn = false;
  bool _hasProfile = false;
  bool _availlableVersion = false;
  String _version = '1.1.1';
  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  _loadStatus() async {
    final isLoggedIn = await isUserLoggedIn();
    final result = await checkForUpdate();
    final hasProfile = await hasEmployerProfile();
    final safe = await getSafe();

    setState(() {
      _isLoggedIn = isLoggedIn;
      if (result['status'] == true) {
        _availlableVersion = result['availlable'];
        _version = result['version'];
      }
      _safe = safe;
      _hasProfile = hasProfile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _availlableVersion
        ? UpgradeVersion(version: _version)
        : _isLoggedIn
            ? _hasProfile
                ? _safe
                    ? const BaseApp()
                    : const SecurityQuestionForm()
                : const ProfileForm()
            : AuthPage();
  }
}
