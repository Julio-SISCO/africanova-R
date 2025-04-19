import 'package:flutter/material.dart';

Widget buildAccessButton(
  String label,
  IconData icon,
  Widget view,
  bool visible,
  Function(Widget) switchView,
) {
  return AnimatedOpacity(
    duration: const Duration(milliseconds: 300),
    opacity: visible ? 1.0 : 0.0,
    child: visible
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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          )
        : const SizedBox.shrink(),
  );
}

Widget buildAnimatedButton(
  String label,
  IconData icon,
  Widget view,
  bool isVisible,
  Function(Widget) switchView,
) {
  return AnimatedOpacity(
    duration: const Duration(milliseconds: 300),
    opacity: isVisible ? 1.0 : 0.0,
    child: isVisible
        ? ElevatedButton.icon(
            onPressed: () => switchView(view),
            icon: Icon(icon),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          )
        : const SizedBox.shrink(),
  );
}

Widget buildActionButton(
    String label, IconData icon, VoidCallback onPressed, bool isLoading) {
  return SizedBox(
    height: 35,
    child: TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFF056148),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
      onPressed: isLoading ? null : onPressed,
      icon: isLoading ? null : Icon(icon, color: Colors.white),
      label: isLoading
          ? CircularProgressIndicator(
              color: Colors.white,
            )
          : Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    ),
  );
}
