import 'package:africanova/base.dart';
import 'package:africanova/controller/auth_controller.dart';
import 'package:africanova/controller/global_controller.dart';
import 'package:africanova/util/check_profil.dart';
import 'package:africanova/view/auth/form_design.dart';
import 'package:africanova/view/auth/profile_form.dart';
import 'package:africanova/view/auth/security_question_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordForgotten extends StatefulWidget {
  final String username;
  const PasswordForgotten({super.key, required this.username});

  @override
  State<PasswordForgotten> createState() => _PasswordForgottenState();
}

class _PasswordForgottenState extends State<PasswordForgotten> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _cfpasswordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscurePassword2 = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _cfpasswordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final password = _passwordController.text;
      final result =
          await resetPassword(username: widget.username, password: password);

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
      setState(() {
        isLoading = false;
      });
      if (result['status'] == true) {
        bool hasProfile = await hasEmployerProfile();
        if (hasProfile) {
          bool safe = await getSafe();
          if (safe) {
            await getGlobalData();
            Get.offAll(const BaseApp());
          } else {
            Get.offAll(const SecurityQuestionForm());
          }
        } else {
          Get.offAll(const ProfileForm());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormDesign(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Retour",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Form(
            key: _formKey,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 40.0, right: 40.0, top: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Reinitialiser votre mot de passe".toUpperCase(),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Mot de passe",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    cursorColor: Colors.black,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: '********',
                      fillColor: Colors.grey.shade300,
                      hintStyle: TextStyle(
                        color: Colors.black,
                      ),
                      filled: true,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(2.0)),
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le mot de passe est requis';
                      }
                      if (value.length < 8) {
                        return 'Le mot de passe doit comporter au moins 8 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Confirmation du Mot de passe",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _cfpasswordController,
                    obscureText: _obscurePassword2,
                    cursorColor: Colors.black,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: '********',
                      fillColor: Colors.grey.shade300,
                      hintStyle: TextStyle(
                        color: Colors.black,
                      ),
                      filled: true,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(2.0)),
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword2
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword2 = !_obscurePassword2;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0 * 2.5),
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Color(0xFF262D4D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                      onPressed: isLoading ? () {} : _login,
                      child: isLoading
                          ? CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              color: Colors.grey,
                            )
                          : Text(
                              'Enregistrer',
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
