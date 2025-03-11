import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/view/components/services/service_side.dart';
import 'package:africanova/view/components/services/service_table.dart';
import 'package:flutter/material.dart';

class ServiceContent extends StatefulWidget {
  final Function(Widget) switchView;
  const ServiceContent({super.key, required this.switchView});

  @override
  State<ServiceContent> createState() => _ServiceContentState();
}

class _ServiceContentState extends State<ServiceContent> {
  late Widget _view = ServiceTable(
    switchView: (Widget w) => widget.switchView(w),
  );
  void changeContent(Widget view) {
    setState(() {
      _view = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              elevation: 0.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _view,
                  ),
                ],
              ),
            ),
          ),
        ),
        buildMenuWithPermission(
          'voir type de services',
          Expanded(
            child: ServiceSide(
              switchView: (Widget w) => widget.switchView(w),
              changeContent: (Widget content) {
                changeContent(content);
              },
              updateLoading: (bool f) {},
            ),
          ),
        ),
      ],
    );
  }
}
