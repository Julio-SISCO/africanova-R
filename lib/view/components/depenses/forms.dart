import 'package:flutter/material.dart';

class DepenseForm extends StatefulWidget {
  const DepenseForm({super.key});

  @override
  State<DepenseForm> createState() => _DepenseFormState();
}

class _DepenseFormState extends State<DepenseForm> {
  final _formKey = GlobalKey<FormState>();
  String? description;
  double montant = 0.0;
  DateTime selectedDate = DateTime.now();
  String status = 'Active';

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
              decoration: const InputDecoration(labelText: 'Description'),
              onSaved: (value) => description = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Montant'),
              keyboardType: TextInputType.number,
              onSaved: (value) => montant = double.tryParse(value ?? '') ?? 0.0,
            ),
            ElevatedButton(
              onPressed: () async {
                final selectedDateTemp = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (selectedDateTemp != null &&
                    selectedDateTemp != selectedDate) {
                  setState(() {
                    selectedDate = selectedDateTemp;
                  });
                }
              },
              child: Text('Choisir la date'),
            ),
            Row(
              children: [
                const Text('Status:'),
                Radio<String>(
                  value: 'Active',
                  groupValue: status,
                  onChanged: (value) {
                    setState(() {
                      status = value!;
                    });
                  },
                ),
                const Text('Active'),
                Radio<String>(
                  value: 'Inactif',
                  groupValue: status,
                  onChanged: (value) {
                    setState(() {
                      status = value!;
                    });
                  },
                ),
                const Text('Inactif'),
              ],
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
