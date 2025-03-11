import 'package:africanova/view/components/services/service_content.dart';
import 'package:africanova/view/components/services/service_header.dart';
import 'package:flutter/material.dart';

class ServiceMain extends StatefulWidget {
  final Function(Widget) switchView;
  const ServiceMain({super.key, required this.switchView});

  @override
  State<ServiceMain> createState() => _ServiceMainState();
}

class _ServiceMainState extends State<ServiceMain> {
  Widget _content = Container();

  void changeContent(Widget content) {
    setState(() {
      _content = content;
    });
  }

  void updateLoading(bool isLoading) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _content = ServiceContent(
      switchView: (Widget w) => widget.switchView(w),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ServiceHead(
            switchView: (Widget w) => widget.switchView(w),
            changeContent: (Widget content) {
              changeContent(content);
            },
            updateLoading: updateLoading,
          ),
        ),
        Expanded(child: _content),
      ],
    );
  }
}
