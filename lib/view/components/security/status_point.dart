import 'package:flutter/material.dart';

class StatusPoint extends StatelessWidget {
  final bool isActive;

  const StatusPoint({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.0,
      height: 10.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.green[800] : Colors.transparent,
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.red,
          width: 2.0,
        ),
      ),
    );
  }
}
