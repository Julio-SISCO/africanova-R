import 'package:flutter/material.dart';

class FormDesign extends StatelessWidget {
  final Widget child;
  const FormDesign({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double totalWidth = constraints.maxWidth;
          double totalHeight = constraints.maxHeight;
          return Stack(
            children: [
              Row(
                children: [
                  Container(
                    width: totalWidth * (3.45 / 9),
                    color: Color(0xFF262D4D),
                  ),
                  Container(
                    width: totalWidth * (5.55 / 9),
                    color: Colors.white,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: totalWidth * .7,
                  height: totalHeight * .8,
                  child: Card(
                    margin: EdgeInsets.all(0.0),
                    elevation: 16.0,
                    child: Row(
                      children: [
                        Container(
                          width: totalWidth * .7 * (3 / 9),
                          color: Color(0xFF262D4D),
                        ),
                        Container(
                          width: totalWidth * .7 * (6 / 9),
                          color: Colors.white,
                          padding: EdgeInsets.all(16.0),
                          child: child,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
