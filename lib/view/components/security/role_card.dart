import 'package:africanova/database/role.dart';
import 'package:africanova/view/components/security/edit_role_form.dart';
import 'package:africanova/view/components/security/role_and_permission.dart';
import 'package:flutter/material.dart';

class RoleCard extends StatefulWidget {
  final Role role;
  const RoleCard({super.key, required this.role});

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  void showRoleEditionForm(BuildContext context, Role role) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return EditRoleForm(role: role);
      },
    );

    if (result != null) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => RoleAndPermission(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: 180.0,
          height: 60.0,
          child: Card(
            elevation: 0.0,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Utilisateurs'.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 11,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Text(
                    widget.role.name.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 5.0,
          right: 5.0,
          child: Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                width: 1.0,
                color: Colors.grey,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: InkWell(
                onTap: () {
                  showRoleEditionForm(context, widget.role);
                },
                child: Icon(
                  Icons.edit,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
