import 'package:africanova/database/permission.dart';
import 'package:africanova/database/role.dart';
import 'package:africanova/provider/permissions_providers.dart';
import 'package:africanova/view/components/security/role_card.dart';
import 'package:flutter/material.dart';

class RelationTable extends StatefulWidget {
  final List<Role> roles;
  final List<Permission> permissions;
  const RelationTable({
    super.key,
    required this.roles,
    required this.permissions,
  });

  @override
  State<RelationTable> createState() => _RelationTableState();
}

class _RelationTableState extends State<RelationTable> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: PaginatedDataTable(
              arrowHeadColor: Colors.black,
              headingRowHeight: 100,
              horizontalMargin: 0,
              columnSpacing: 24,
              columns: [
                DataColumn(
                  headingRowAlignment: MainAxisAlignment.start,
                  label: Text(
                    "Permissions",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...List.generate(
                  widget.roles.length,
                  (index) => DataColumn(
                    label: RoleCard(
                      role: widget.roles[index],
                    ),
                  ),
                ),
              ],
              source: RoleDataSource(
                roles: widget.roles,
                permissions: widget.permissions,
              ),
              rowsPerPage: 10,
              onRowsPerPageChanged: null,
            ),
          ),
        ],
      ),
    );
  }
}
