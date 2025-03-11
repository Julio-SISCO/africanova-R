import 'package:africanova/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlertNotif extends StatelessWidget {
  const AlertNotif({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // _buildIconWithDropdown(
        //   Icons.notifications,
        //   'Alertes',
        //   context,
        // ),
        // SizedBox(width: 16.0),
        // _buildIconWithDropdown(
        //   Icons.email_outlined,
        //   'Notifications',
        //   context,
        // ),
        IconButton(
          onPressed: null,
          icon: Icon(
            Icons.notifications,
            color: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .tertiary,
          ),
        ),
      ],
    );
  }

  Widget buildIconWithDropdown(
      IconData icon, String label, BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PopupMenuButton<String>(
          icon: Icon(
            icon,
          ),
          onSelected: (value) {},
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'option1',
              child: Text('Option 1'),
            ),
            const PopupMenuItem<String>(
              value: 'option2',
              child: Text('Option 2'),
            ),
          ],
        ),
        Positioned(
          right: 5,
          top: 5,
          child: Container(
            height: 10,
            width: 10,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
