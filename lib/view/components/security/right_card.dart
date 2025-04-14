import 'package:africanova/database/employer.dart';
import 'package:africanova/database/permission.dart';
import 'package:africanova/database/role.dart';
import 'package:africanova/database/user.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class RightCard extends StatefulWidget {
  final Function(List<String>) updatePermissions;
  final User user;
  const RightCard(
      {super.key, required this.user, required this.updatePermissions});

  @override
  State<RightCard> createState() => _RightCardState();
}

class _RightCardState extends State<RightCard> {
  List<Permission> _permissions = [];
  List<Permission> _filteredPermissions = [];
  List<String> _selectedPermissions = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPermissions();

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredPermissions = _permissions
            .where((p) => p.name.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  Future<void> _loadPermissions() async {
    final box = await Hive.openBox<Permission>('permissionBox');
    final permissions = box.values.toList();

    setState(() {
      _permissions = permissions;
      _filteredPermissions = permissions;
      _selectedPermissions = widget.user.permissions == null
          ? []
          : widget.user.permissions!.map((e) => e.name).toList();
    });
  }

  void _togglePermission(String permission) {
    setState(() {
      if (_selectedPermissions.contains(permission)) {
        _selectedPermissions.remove(permission);
      } else {
        _selectedPermissions.add(permission);
      }
    });
    widget.updatePermissions(_selectedPermissions);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 2.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Permissions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Liste scrollable
            LayoutBuilder(builder: (context, constraints) {
              return SizedBox(
                height: constraints.maxWidth * 1.32,
                child: ListView(
                  children: _filteredPermissions.map((permission) {
                    return _buildPermissionCheckbox(permission.name);
                  }).toList(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCheckbox(String permission) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              permission,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Checkbox(
            value: _selectedPermissions.contains(permission),
            onChanged: (bool? value) {
              _togglePermission(permission);
            },
            activeColor: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .secondary,
          ),
        ],
      ),
    );
  }
}

class RoleRightCard extends StatefulWidget {
  final Function(List<String>) updateRoles;
  final User user;
  const RoleRightCard({
    super.key,
    required this.user,
    required this.updateRoles,
  });

  @override
  State<RoleRightCard> createState() => _RoleRightCardState();
}

class _RoleRightCardState extends State<RoleRightCard> {
  List<Role> _roles = [];
  List<String> _selectedRoles = [];

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    final box = await Hive.openBox<Role>('roleBox');
    final roles = box.values.toList();

    setState(() {
      _roles = roles;
      _selectedRoles = widget.user.roles == null
          ? []
          : widget.user.roles!.map((e) => e.name).toList();
    });
  }

  void _toggleRole(String role) {
    setState(() {
      if (_selectedRoles.contains(role)) {
        _selectedRoles.remove(role);
      } else {
        _selectedRoles.add(role);
      }
    });
    widget.updateRoles(_selectedRoles);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rôles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ..._roles.map((role) => _buildRoleCheckbox(role.name)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCheckbox(String role) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            role,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Checkbox(
            activeColor: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .secondary,
            value: _selectedRoles.contains(role),
            onChanged: (bool? value) {
              setState(() {
                _toggleRole(role);
              });
            },
          ),
        ],
      ),
    );
  }
}

class UserInfoCard extends StatefulWidget {
  final User user;
  final GlobalKey<FormState> formKey;
  final Function(String) updateUsername;
  final Function(int) updateEmployer;
  final Function(bool) updateIsActive;

  const UserInfoCard({
    super.key,
    required this.user,
    required this.updateUsername,
    required this.updateEmployer,
    required this.updateIsActive,
    required this.formKey,
  });

  @override
  State<UserInfoCard> createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<UserInfoCard> {
  bool _isActive = false;
  Employer? _selectedEmployer;
  final TextEditingController _usernameController = TextEditingController();
  List<Employer> _employers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final box = await Hive.openBox<Employer>('employerBox');
    final employers = box.values.toList();
    setState(() {
      _employers = employers;
      _selectedEmployer =
          employers.firstWhere((e) => e.id == widget.user.employer?.id);
      _usernameController.text = widget.user.username;
      _isActive = widget.user.isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Information du compte',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildDateInfoRow('Date de création', widget.user.createdAt),
            _buildDateInfoRow('Dernière activité', widget.user.lastLogin),
            const Divider(),
            _buildInfoRow('Nom utilisateur', _usernameController),
            _buildInfoDropRow('Employer'),
            _buildInfoCheckRow('Compte actif'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoDropRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<Employer>(
              value: _selectedEmployer,
              decoration: const InputDecoration(
                labelText: 'Employer',
                border: OutlineInputBorder(),
              ),
              items: _employers.map((Employer employer) {
                return DropdownMenuItem<Employer>(
                  value: employer,
                  child: Text(
                    '${employer.prenom} ${employer.nom}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEmployer = value;
                });
                widget.updateEmployer(value!.id ?? 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCheckRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Checkbox(
            activeColor: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .secondary,
            value: _isActive,
            onChanged: (bool? value) {
              setState(() {
                _isActive = value ?? false;
              });
              widget.updateIsActive(_isActive);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Form(
              key: widget.formKey,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ce champ ne peut pas être vide.";
                  }
                  return null;
                },
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => widget.updateUsername(value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfoRow(String label, DateTime? date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              date == null ? 'Aucune activité détectée' : formatDate(date),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
