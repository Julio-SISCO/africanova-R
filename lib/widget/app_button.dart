import 'package:flutter/material.dart';

Widget buildAccessButton(
  String label,
  IconData icon,
  Widget view,
  bool visible,
  Function(Widget) switchView,
) {
  return visible
      ? SizedBox(
          height: 35,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              
              backgroundColor: const Color(0xFF056148),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            onPressed: () => switchView(view),
            icon: Icon(icon, color: Colors.white),
            label: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        )
      : const SizedBox.shrink();
}

Widget buildActionButton(
  String label,
  IconData icon,
  Widget view,
  bool visible,
  Function(Widget) switchView,
) {
  return visible
      ? SizedBox(
          height: 35,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              
              backgroundColor: const Color(0xFF056148),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            onPressed: () => switchView(view),
            icon: Icon(icon, color: Colors.white),
            label: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        )
      : const SizedBox.shrink();
}
