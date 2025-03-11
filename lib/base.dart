import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/dashboard/dashboard.dart';
import 'package:africanova/view/layouts/app_header.dart';
import 'package:africanova/view/layouts/app_sidebar.dart';
import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    _view = Dashboard(
      switchView: (Widget w) {
        _switchView(w);
      },
    );
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
          Provider.of<ThemeProvider>(context).themeData.colorScheme.surface,
      body: Row(
        children: [
          if (!_hideSideBar)
            Expanded(child: AppSidebar(switchView: _switchView)),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                AppHeader(switchView: _switchView, hideSideBar: _toggleHide),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    margin: EdgeInsets.all(.0),
                    elevation: 0.0,
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .primary,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: _view,
                    ),
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
