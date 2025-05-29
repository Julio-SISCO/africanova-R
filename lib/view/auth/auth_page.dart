import 'package:africanova/base.dart';
import 'package:africanova/controller/auth_controller.dart';
import 'package:africanova/controller/global_controller.dart';
import 'package:africanova/provider/auth_provider.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/util/check_profil.dart';
import 'package:africanova/view/auth/form_design.dart';
import 'package:africanova/view/auth/profile_form.dart';
import 'package:africanova/view/auth/security_question_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cfpasswordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscurePassword2 = true;
  bool _register = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _cfpasswordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final username = _usernameController.text;
      final password = _passwordController.text;
      Map<String, dynamic> result = {};
      if (_register) {
        result = await register(username: username, password: password);
      } else {
        result = await login(username: username, password: password);
      }
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
        startSessionCheck();
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
      setState(() {
        isLoading = false;
      });
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
            child: Text(
              "Besoin d'aide ?",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double totalWidth = constraints.maxWidth;
                      return Wrap(
                        children: [
                          SizedBox(
                            height: 40,
                            width: totalWidth / 2,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    _register ? Colors.grey : Color(0xFF262D4D),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                              ),
                              onPressed: isLoading
                                  ? () {}
                                  : () {
                                      setState(() {
                                        _register = false;
                                      });
                                    },
                              child: const Text(
                                'Se connecter',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            width: totalWidth / 2,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: !_register
                                    ? Colors.grey
                                    : Color(0xFF262D4D),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                              ),
                              onPressed: isLoading
                                  ? () {}
                                  : () {
                                      setState(() {
                                        _register = true;
                                      });
                                    },
                              child: const Text(
                                'Créer un compte',
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
                      );
                    },
                  ),
                  SizedBox(height: 16.0),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      _register
                          ? "Créez un compte".toUpperCase()
                          : "Connectez-vous".toUpperCase(),
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
                      "Nom d'utilisateur",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _usernameController,
                    cursorColor: Colors.black,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'johndoe',
                      fillColor: Colors.grey.shade300,
                      filled: true,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nom d\'utilisateur est requis';
                      }
                      if (value.contains(' ')) {
                        return 'Le nom d\'utilisateur ne doit pas contenir d\'espaces';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
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
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
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
                  if (_register) ...[
                    const SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Confirmation du mot de passe",
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
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
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
                  ],
                  if (!_register)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.to(const SecurityQuestionForm(toCheck: true));
                        },
                        child: const Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16.0 * 2.5),
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
                      onPressed: isLoading ? () {} : _login,
                      child: isLoading
                          ? CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              color: Provider.of<ThemeProvider>(context)
                                  .themeData
                                  .colorScheme
                                  .secondary,
                            )
                          : Text(
                              _register ? 'Créer le compte' : 'Connecter',
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
