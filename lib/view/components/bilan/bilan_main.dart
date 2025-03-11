import 'package:africanova/view/components/bilan/bilan_stock.dart';
import 'package:africanova/view/components/bilan/bilan_header.dart';
import 'package:flutter/material.dart';

class BilanMain extends StatefulWidget {
  const BilanMain({super.key});

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
    _content = BilanStock();
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
