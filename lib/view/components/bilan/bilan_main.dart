import 'package:africanova/view/components/bilan/bilan_stock.dart';
import 'package:africanova/view/components/bilan/bilan_header.dart';
import 'package:flutter/material.dart';

class BilanMain extends StatefulWidget {
  final Function(Widget) switchView;
  const BilanMain({super.key, required this.switchView});

  @override
  State<BilanMain> createState() => _BilanMainState();
}

class _BilanMainState extends State<BilanMain> {
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
    _content = BilanStock(switchView: widget.switchView);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: BilanHeader(
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
