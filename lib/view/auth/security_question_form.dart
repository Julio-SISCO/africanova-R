import 'package:africanova/base.dart';
import 'package:africanova/controller/auth_controller.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/view/auth/form_design.dart';
import 'package:africanova/view/auth/password_forgotten.dart';
import 'package:africanova/widget/input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SecurityQuestionForm extends StatefulWidget {
  final bool toCheck;
  const SecurityQuestionForm({super.key, this.toCheck = false});

  @override
  State<SecurityQuestionForm> createState() => _SecurityQuestionFormState();
}

class _SecurityQuestionFormState extends State<SecurityQuestionForm> {
  final _formKey = GlobalKey<FormState>();
  final _responseController = TextEditingController();
  final _usernameController = TextEditingController();
  bool isLoading = false;
  final List<String> _questions = [
    "Quel était le nom de votre premier animal de compagnie ?",
    "Dans quelle ville êtes-vous né(e) ?",
    "Quel est le prénom de votre meilleur(e) ami(e) d'enfance ?",
    "Quel était le modèle de votre première voiture ?",
    "Quel est le nom de votre école primaire ?",
    "Quel est le nom de jeune fille de votre mère ?",
    "Quel est le titre de votre livre ou film préféré ?",
    "Quel était le nom de votre premier employeur ?"
  ];

  String? _selectedQuestion;
  String? _questionError;
  @override
  void dispose() {
    _selectedQuestion = null;
    _responseController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _validate() async {
    if (_formKey.currentState!.validate() && _selectedQuestion != null) {
      setState(() {
        isLoading = true;
      });
      if (!widget.toCheck) {
        final result = await setSecurityQuestion(
          question: _selectedQuestion!,
          response: _responseController.text,
        );

        Get.snackbar(
          '',
          result["message"],
          titleText: SizedBox.shrink(),
          messageText: Center(
            child: Text(
              result["message"],
              style: TextStyle(
                color: Colors.white,
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
          Get.offAll(const BaseApp());
        }
      } else {
        final result = await verifySecurityQuestion(
          username: _usernameController.text,
          question: _selectedQuestion!,
          response: _responseController.text,
        );

        Get.snackbar(
          '',
          result["message"],
          titleText: SizedBox.shrink(),
          messageText: Center(
            child: Text(
              result["message"],
              style: TextStyle(
                color: Colors.white,
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
          Get.to(PasswordForgotten(username: _usernameController.text));
        }
      }
    } else if (_selectedQuestion == null) {
      setState(() {
        _questionError = "Choississez une question de sécurité";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormDesign(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 16.0),
            if (widget.toCheck)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    "Retour",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Questions de sécurité".toUpperCase(),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.0),
                  if (widget.toCheck)
                    Wrap(
                      children: [
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
                        DefaultInputField(
                          controller: _usernameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Saisissez votre nom d\'utilisateur';
                            }
                            return null;
                          },
                          labelText: 'johdoe',
                        ),
                      ],
                    ),
                  const SizedBox(height: 16.0),
                  Wrap(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Question *",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        padding: EdgeInsets.all(0.0),
                        value: _selectedQuestion,
                        icon: Icon(
                          Icons.arrow_drop_down_circle_sharp,
                          color: Colors.grey,
                        ),
                        dropdownColor: Colors.grey.shade200,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.6,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Choissiez une question',
                          fillColor: Colors.grey.shade300,
                          filled: true,
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16.6,
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(
                              Radius.circular(2.0),
                            ),
                          ),
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16.6,
                          ),
                        ),
                        items: _questions.map((String question) {
                          return DropdownMenuItem<String>(
                            value: question,
                            child: Text(question),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedQuestion = newValue;
                          });
                        },
                      ),
                      if (_questionError != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            _questionError!,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.red[900],
                            ),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Wrap(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Réponse *",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DefaultInputField(
                        controller: _responseController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Saisissez votre réponse';
                          }
                          return null;
                        },
                        labelText: 'Réponse à la question',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Color(0xFF262D4D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0),
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
          ],
        ),
      ),
    );
  }
}
