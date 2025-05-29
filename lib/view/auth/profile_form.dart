import 'package:africanova/base.dart';
import 'package:africanova/controller/auth_controller.dart';
import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/controller/global_controller.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/auth/form_design.dart';
import 'package:africanova/view/auth/security_question_form.dart';
import 'package:africanova/widget/input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _phoneController = TextEditingController();
  final _adresseController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  void _validate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      // Récupérez les valeurs des contrôleurs
      final nom = _nomController.text;
      final prenom = _prenomController.text;
      final email = _emailController.text;
      final contact = _contactController.text;
      final phone = _phoneController.text;
      final adresse = _adresseController.text;

      final result = await setProfile(
        nom: nom,
        prenom: prenom,
        adresse: adresse,
        contact: contact,
        email: email,
        phone: phone,
      );

      Get.snackbar(
        '',
        result["message"],
        titleText: SizedBox.shrink(),
        messageText: Center(
          child: Text(
            result["message"],
            style: TextStyle(
              color: Color(0xFF262D4D),
            ),
          ),
        ),
        maxWidth: 400,
        snackPosition: SnackPosition.BOTTOM,
      );
      if (result['status'] == true) {
        bool safe = await getSafe();
        if (safe) {
          await getGlobalData();
          Get.offAll(const BaseApp());
        } else {
          Get.offAll(const SecurityQuestionForm());
        }
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormDesign(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  SizedBox(height: 16.0),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Créer un profil".toUpperCase(),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Nom*",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DefaultInputField(
                              labelText: 'Doe',
                              controller: _nomController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Saisissez votre nom';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Wrap(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Prenoms*",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DefaultInputField(
                              labelText: 'john',
                              controller: _prenomController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Saisissez vos prénoms';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Wrap(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Adresse email",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DefaultInputField(
                        controller: _emailController,
                        labelText: 'adresse@email.com',
                        validator: validateEmail,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Contact*",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DefaultInputField(
                              labelText: '90 00 00 00',
                              controller: _contactController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Le numéro est requis';
                                }
                                if (!RegExp(r'^[0-9]{8}$').hasMatch(value)) {
                                  return 'Le numéro doit être de 8 chiffres, sans indicatif';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Wrap(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Autre contact",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DefaultInputField(
                              controller: _phoneController,
                              labelText: '90 00 00 00 ',
                              validator: (value) {
                                if (value != null &&
                                    value.isNotEmpty &&
                                    !RegExp(r'^[0-9]{8}$').hasMatch(value)) {
                                  return 'Le numéro doit être de 8 chiffres, sans indicatif';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Wrap(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Adresse *",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DefaultInputField(
                        controller: _adresseController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Saisissez votre adresse';
                          }
                          return null;
                        },
                        labelText: 'Quartier, Ville - Pays',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF262D4D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      onPressed: isLoading ? () {} : _validate,
                      child: isLoading
                          ? CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              color: Provider.of<ThemeProvider>(context)
                                  .themeData
                                  .colorScheme
                                  .secondary,
                            )
                          : Text(
                              'Continuer',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
