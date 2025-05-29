import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/components/security/user_role_permission.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccessButton extends StatefulWidget {
  final Function(Widget?) switchView;
  const AccessButton({super.key, required this.switchView});

  @override
  State<AccessButton> createState() => _PageButtonState();
}

class _PageButtonState extends State<AccessButton> {
  String selectedButton = "Acceuil";

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      margin: EdgeInsets.all(0.0),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildButton(context, "Acceuil", Icons.home, () {
                setState(() => selectedButton = "Acceuil");
                widget.switchView(null);
              }),
              _buildButton(context, "Nouveau", Icons.add, () {}),
              _buildButton(context, "Edition", Icons.edit, () {}),
              _buildButton(context, "Utilisateurs", Icons.group, () {
                setState(() => selectedButton = "Utilisateurs");
                widget.switchView(
                  UserRolePermission(switchView: widget.switchView),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String libelle, IconData icon,
      VoidCallback onPressed) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        bool isSelected = selectedButton == libelle;

        return SizedBox(
          height: 40,
          width: 120,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: isSelected
                  ? const Color.fromARGB(255, 5, 202, 133).withOpacity(0.4)
                  : themeProvider.themeData.colorScheme.primary,
              foregroundColor: themeProvider.themeData.colorScheme.tertiary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0)),
            ),
            onPressed: onPressed,
            icon: Icon(icon,
                size: 18, color: themeProvider.themeData.colorScheme.tertiary),
            label: Text(
              libelle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        );
      },
    );
  }
}
