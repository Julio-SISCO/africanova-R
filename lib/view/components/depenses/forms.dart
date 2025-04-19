import 'package:flutter/material.dart';


class CategorieDepenseForm extends StatefulWidget {
  const CategorieDepenseForm({super.key});

  @override
  State<CategorieDepenseForm> createState() => _CategorieDepenseFormState();
}

class _CategorieDepenseFormState extends State<CategorieDepenseForm> {
  final _formKey = GlobalKey<FormState>();
  String? nom;
  String? description;
  String? typeDepense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nom'),
              onSaved: (value) => nom = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              onSaved: (value) => description = value,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Type de dépense'),
              value: typeDepense,
              items: ['Type 1', 'Type 2', 'Type 3']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  typeDepense = value;
                });
              },
              onSaved: (value) => typeDepense = value,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                }
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        ),
      ),
    );
  }
}

class TypeDepenseForm extends StatefulWidget {
  const TypeDepenseForm({super.key});

  @override
  State<TypeDepenseForm> createState() => _TypeDepenseFormState();
}

class _TypeDepenseFormState extends State<TypeDepenseForm> {
  final _formKey = GlobalKey<FormState>();
  String? nom;
  String? description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nom'),
              onSaved: (value) => nom = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              onSaved: (value) => description = value,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                }
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        ),
      ),
    );
  }
}
