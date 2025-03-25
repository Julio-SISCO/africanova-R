import 'package:africanova/controller/employer_controller.dart';
import 'package:africanova/database/employer.dart';

import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/widget/input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class EmployerForm extends StatefulWidget {
  final Employer? editableEmployer;

  const EmployerForm({super.key, this.editableEmployer});

  @override
  State<EmployerForm> createState() => _EmployerFormState();
}

class _EmployerFormState extends State<EmployerForm> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    if (widget.editableEmployer != null) {
      _nomController.text = widget.editableEmployer!.nom;
      _prenomController.text = widget.editableEmployer!.prenom;
      _contactController.text = widget.editableEmployer!.contact ?? '';
      _phoneController.text = widget.editableEmployer!.phone ?? '';
      _emailController.text = widget.editableEmployer!.email ?? '';
      _adresseController.text = widget.editableEmployer!.adresse ?? '';
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      Map<String, dynamic> result = {};
      if (widget.editableEmployer == null) {
        result = await sendEmployer(
          nom: _nomController.text,
          prenom: _prenomController.text,
          contact: _contactController.text,
          adresse: _adresseController.text,
          phone: _phoneController.text,
          email: _emailController.text,
        );
      } else {
        result = await updateEmployer(
          id: widget.editableEmployer?.id ?? 0,
          nom: _nomController.text,
          prenom: _prenomController.text,
          contact: _contactController.text,
          adresse: _adresseController.text,
          phone: _phoneController.text,
          email: _emailController.text,
        );
      }
      if (result['status'] == true) {
        _nomController.clear();
        _prenomController.clear();
        _prenomController.clear();
        _contactController.clear();
        _phoneController.clear();
        _emailController.clear();
        _adresseController.clear();
      }

      Get.snackbar(
        '',
        result["message"],
        titleText: SizedBox.shrink(),
        messageText: Center(
          child: Text(result["message"]),
        ),
        maxWidth: 300,
        snackPosition: SnackPosition.BOTTOM,
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 5,
          vertical: MediaQuery.of(context).size.height / 7),
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        padding: EdgeInsets.all(
          16.0 * 2,
        ),
        child: Form(
          key: _formKey,
          child: _form(context),
        ),
      ),
    );
  }

  Widget _form(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _nomController,
                cursorColor: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .tertiary,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  filled: true,
                  fillColor: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .primary,
                  floatingLabelStyle: TextStyle(
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .tertiary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom de l\'employer';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: TextFormField(
                controller: _prenomController,
                cursorColor: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .tertiary,
                decoration: InputDecoration(
                  labelText: 'prenom',
                  filled: true,
                  fillColor: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .primary,
                  floatingLabelStyle: TextStyle(
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .tertiary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le prenom de l\'employer';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _emailController,
          cursorColor: Provider.of<ThemeProvider>(context)
              .themeData
              .colorScheme
              .tertiary,
          decoration: InputDecoration(
            labelText: 'Adresse email',
            filled: true,
            fillColor: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .primary,
            floatingLabelStyle: TextStyle(
              color: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .tertiary,
            ),
          ),
          validator: validateEmail,
        ),
        const SizedBox(height: 16.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _contactController,
                cursorColor: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .tertiary,
                decoration: InputDecoration(
                  labelText: 'Contact',
                  filled: true,
                  fillColor: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .primary,
                  floatingLabelStyle: TextStyle(
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .tertiary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le contact du employer';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Fax',
                  filled: true,
                  fillColor: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .primary,
                  floatingLabelStyle: TextStyle(
                    color: Provider.of<ThemeProvider>(context)
                        .themeData
                        .colorScheme
                        .tertiary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _adresseController,
          cursorColor: Provider.of<ThemeProvider>(context)
              .themeData
              .colorScheme
              .tertiary,
          decoration: InputDecoration(
            labelText: 'Adresse',
            filled: true,
            fillColor: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .primary,
            floatingLabelStyle: TextStyle(
              color: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .tertiary,
            ),
          ),
        ),
        const SizedBox(height: 16.0 * 4),
        SizedBox(
          height: 16.0 * 3,
          width: MediaQuery.of(context).size.width * .3,
          child: TextButton(
            style: TextButton.styleFrom(
              elevation: 2.0,
              backgroundColor: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .primary,
              foregroundColor: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .tertiary,
              side: BorderSide(
                width: 2.0,
                color: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .primary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: isLoading
                ? null
                : () {
                    _submit();
                  },
            child: const Text(
              'Enregistrer',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
