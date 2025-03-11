import 'package:africanova/static/theme.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchField2 extends StatelessWidget {
  const SearchField2({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: TextFormField(
        controller: searchController,
        validator: (value) {
          if (value == null) {
            return 'Veuillez saisir une recherche';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: 'Rechercher',
          fillColor: Colors.grey[300],
          filled: true,
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
          suffixIcon: InkWell(
            onTap: () {
              if (formKey.currentState!.validate()) {
                final keyWord = searchController.text;
                debugPrint(keyWord);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16.0 * 0.55),
              decoration: const BoxDecoration(
                color: couleurFond,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: const Icon(
                Icons.search,
                color: bgColor,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final searchController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 40,
      child: Form(
        key: formKey,
        child: TextFormField(
          controller: searchController,
          validator: (value) {
            if (value == null) {
              return 'Veuillez saisir une recherche';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Rechercher',
            fillColor: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .primary,
            filled: true,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final keyWord = searchController.text;
                  debugPrint(keyWord);
                }
              },
              icon: Icon(
                Icons.search,
                color: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .tertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
