import 'package:africanova/controller/transfert_controller.Dart';
import 'package:africanova/database/transfert.dart';
import 'package:flutter/material.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/widget/input_field.dart';
import 'package:africanova/view/components/transferts/resume_transfert.dart';
import 'package:get/get.dart';

class TransfertForm extends StatefulWidget {
  const TransfertForm({super.key});

  @override
  State<TransfertForm> createState() => _TransfertFormState();
}

class _TransfertFormState extends State<TransfertForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final numeroController = TextEditingController();
  final montantController = TextEditingController();
  final commissionController = TextEditingController();
  final referenceController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation, _slideAnimation;

  DateTime _selectedDate = DateTime.now();
  String? selectedType, selectedSubtype, selectedNetwork;
  bool isLoading = false;
  final types = ['Transfert d\'argent', 'Recharge d\'unités'];
  final subtypes = {
    'Transfert d\'argent': ['Retrait', 'Dépôt'],
    'Recharge d\'unités': [
      'Forfait internet',
      'Forfait appel',
      'Crédit simple'
    ],
  };
  final networks = {
    'Transfert d\'argent': ['Flooz', 'Mixx By Yas'],
    'Recharge d\'unités': ['Moov Africa', 'Yas Togo'],
  };
  final images = {
    'Moov Africa': 'assets/images/moovafrica.jpeg',
    'Yas Togo': 'assets/images/yas.png',
    'Mixx By Yas': 'assets/images/mixxbyyas.png',
    'Flooz': 'assets/images/flooz.png',
  };
  final values = {
    'Moov Africa': 'moov africa',
    'Yas Togo': 'yas togo',
    'Mixx By Yas': 'mixx by yas',
    'Flooz': 'flooz',
    "Retrait": 'retrait',
    "Dépôt": 'depot',
    "Forfait internet": 'forfait internet',
    "Forfait appel": 'forfait appel',
    "Recharge d'unités": 'recharge unite',
    "Transfert d'argent": 'transfert argent',
    "Crédit simple": 'credit simple',
  };
  final icons = {
    'Transfert d\'argent': Icons.attach_money,
    'Recharge d\'unités': Icons.phone_android,
    'Retrait': Icons.arrow_downward,
    'Dépôt': Icons.arrow_upward,
    'Forfait internet': Icons.wifi,
    'Forfait appel': Icons.phone,
    'Crédit simple': Icons.credit_score,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _slideAnimation = Tween(begin: 50.0, end: 0.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();

    numeroController.addListener(() => setState(() {}));
    montantController.addListener(() => setState(() {}));
    commissionController.addListener(() => setState(() {}));
    referenceController.addListener(() => setState(() {}));
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        selectedType != null &&
        selectedSubtype != null &&
        selectedNetwork != null) {
      setState(() {
        isLoading = true;
      });

      try {
        final Transfert transfert = Transfert(
          contact: numeroController.text,
          montant: double.parse(montantController.text),
          commission: double.parse(commissionController.text),
          type: values[selectedSubtype] ?? '',
          reseau: values[selectedNetwork] ?? '',
          categorie: values[selectedType] ?? '',
          date: _selectedDate,
          reference: referenceController.text.isNotEmpty
              ? referenceController.text
              : null,
        );

        final result = await sendTransfert(transfert);

        if (result['status']) {
          setState(() {
            numeroController.clear();
            montantController.clear();
            commissionController.clear();
            referenceController.clear();
            selectedType = null;
            selectedSubtype = null;
            selectedNetwork = null;
            _selectedDate = DateTime.now();
          });
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
      } catch (e) {
        Get.snackbar(
          '',
          'Une erreur inattendue s\'est produite.',
          titleText: SizedBox.shrink(),
          messageText: Center(
            child: Text('Une erreur inattendue s\'est produite.'),
          ),
          maxWidth: 300,
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      Get.snackbar(
        '',
        'Sélectionnez toutes les options requises.',
        titleText: SizedBox.shrink(),
        messageText: Center(
          child: Text('Sélectionnez toutes les options requises.'),
        ),
        maxWidth: 300,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _animatedSection(_buildForm(), false)),
          const SizedBox(width: 32),
          Expanded(
            child: _animatedSection(
              ResumeTransfert(
                type: selectedType,
                subtype: selectedSubtype,
                network: selectedNetwork,
                numero: numeroController.text,
                montant: double.tryParse(montantController.text) ?? 0,
                commission: double.tryParse(commissionController.text) ?? 0,
                date: _selectedDate,
                reference: referenceController.text,
                onSubmit: _submitForm,
                isLoading: isLoading,
              ),
              true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedSection(Widget child, bool reverse) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) => Transform.translate(
        offset:
            Offset(reverse ? -_slideAnimation.value : _slideAnimation.value, 0),
        child: Opacity(opacity: _fadeAnimation.value, child: child),
      ),
    );
  }

  Widget _buildRadioOptions({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String?) onChanged,
    required BoxConstraints constraints,
    bool useIcon = true,
    bool useImage = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: options.map((option) {
            final selected = selectedValue == option;
            return SizedBox(
              width: constraints.maxWidth / 2 - 16,
              child: Theme(
                data: Theme.of(context).copyWith(
                  iconTheme:
                      IconThemeData(color: selected ? Colors.white : null),
                ),
                child: RadioListTile<String>(
                  selected: selected,
                  selectedTileColor: Colors.green,
                  value: option,
                  groupValue: selectedValue,
                  onChanged: onChanged,
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      if (useImage)
                        Image.asset(
                            images[option] ?? 'assets/images/placeholder.png',
                            width: 30,
                            height: 20,
                            fit: BoxFit.cover)
                      else if (useIcon)
                        Icon(icons[option] ?? Icons.circle,
                            color: selected ? Colors.white : null),
                      Text(option,
                          style:
                              TextStyle(color: selected ? Colors.white : null)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LayoutBuilder(builder: (context, constraints) {
            return _buildRadioOptions(
              title: 'Catégorie de transfert',
              options: types,
              selectedValue: selectedType,
              onChanged: (val) => setState(() {
                selectedType = val;
                selectedSubtype = selectedNetwork = null;
              }),
              constraints: constraints,
            );
          }),
          if (selectedType != null) ...[
            LayoutBuilder(builder: (context, constraints) {
              return _buildRadioOptions(
                title: 'Type de transfert',
                options: subtypes[selectedType]!,
                selectedValue: selectedSubtype,
                onChanged: (val) => setState(() => selectedSubtype = val),
                constraints: constraints,
              );
            }),
            LayoutBuilder(builder: (context, constraints) {
              return _buildRadioOptions(
                title: 'Réseau',
                options: networks[selectedType]!,
                selectedValue: selectedNetwork,
                onChanged: (val) => setState(() => selectedNetwork = val),
                constraints: constraints,
                useIcon: false,
                useImage: true,
              );
            }),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildNumberInputField(
                  'Montant de Transfert',
                  montantController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un montant.';
                    }
                    final montant = double.tryParse(value);
                    if (montant == null || montant <= 0) {
                      return 'Veuillez entrer un montant valide.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date de Transfert',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      buildDatePicker(
                        initialDate: _selectedDate,
                        onDateChanged: (newDate) =>
                            setState(() => _selectedDate = newDate),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          buildNumberInputField(
            'Numéro de téléphone',
            numeroController,
            prefix: 'Tel.',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un numéro de téléphone.';
              }
              if (value.length != 8) {
                return 'Le numéro doit contenir exactement 8 chiffres.';
              }
              if (double.tryParse(value) == null) {
                return 'Le numéro doit contenir uniquement des chiffres.';
              }
              return null;
            },
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildNumberInputField(
                  'Commission',
                  commissionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une commission.';
                    }
                    final commission = double.tryParse(value);
                    if (commission == null || commission < 0) {
                      return 'Veuillez entrer une commission valide.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: buildNumberInputField(
                  'Référence (optionnelle)',
                  referenceController,
                  validator: (_) => null,
                  prefix: 'Réf.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
