import 'package:africanova/util/string_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DefaultInputField extends StatelessWidget {
  const DefaultInputField({
    super.key,
    required this.controller,
    this.validator,
    required this.labelText,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: (value) {
        controller.value = TextEditingValue(
          text: capitalizeEachWord(value),
          selection: controller.selection,
        );
      },
      cursorColor: Colors.black,
      style: TextStyle(
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: labelText,
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
      validator: validator,
    );
  }
}

String? validateEmail(String? value) {
  String pattern =
      r"^[a-zA-Z0-9]+([._%+-]?[a-zA-Z0-9]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z]{2,})+$";
  RegExp regex = RegExp(pattern);

  if (value != null && value.isNotEmpty) {
    if (!regex.hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
  }
  return null;
}

Widget buildNumberInputField(
  String label,
  TextEditingController controller, {
  String prefix = 'FCFA',
  String suffix = '',
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            prefixText: '$prefix ',
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
          ],
        ),
      ],
    ),
  );
}
