import 'package:africanova/database/permission.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/dashboard/dashboard.dart';
import 'package:africanova/view/layouts/app_header.dart';
import 'package:africanova/view/layouts/app_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class BaseApp extends StatefulWidget {
  const BaseApp({super.key});

  @override
  State<BaseApp> createState() => _BaseAppState();
}

class _BaseAppState extends State<BaseApp> {
  late Widget _view = Dashboard(
    switchView: (Widget w) {
      _switchView(w);
    },
  );
  bool _hideSideBar = false;
  List<String> _userPermissions = [];

  @override
  void initState() {
    super.initState();
    _view = Dashboard(
      switchView: (Widget w) {
        _switchView(w);
      },
    );
    _loadPermissions();
  }

  void _loadPermissions() async {
    final box = Hive.box<Permission>('userPermissionBox');
    setState(() {
      _userPermissions = box.values.map((e) => e.name).toList();
    });
  }

  void _switchView(Widget view) {
    setState(() {
      _view = view;
    });
  }

  void _toggleHide() {
    setState(() {
      _hideSideBar = !_hideSideBar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
      body: Row(
        children: [
          if (!_hideSideBar)
            Expanded(
              child: AppSidebar(
                switchView: _switchView,
                userPermissions:
                    _userPermissions, // Transmettre les permissions
              ),
            ),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                AppHeader(switchView: _switchView, hideSideBar: _toggleHide),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .primary,
                    child: _view,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
