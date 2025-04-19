import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/widget/app_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResumeTransfert extends StatelessWidget {
  final String? type;
  final String? subtype;
  final String? network;
  final String numero;
  final double montant;
  final double commission;
  final DateTime date;
  final String reference;
  final VoidCallback onSubmit;
  final bool isLoading;

  const ResumeTransfert({
    super.key,
    required this.type,
    required this.subtype,
    required this.network,
    required this.numero,
    required this.montant,
    required this.commission,
    required this.date,
    required this.reference,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    String formatNumeroDeuxParDeux(String numero) {
      final cleaned = numero.replaceAll(' ', '');
      final buffer = StringBuffer();
      for (int i = 0; i < cleaned.length; i += 2) {
        if (i + 2 <= cleaned.length) {
          buffer.write(cleaned.substring(i, i + 2));
        } else {
          buffer.write(cleaned.substring(i));
        }
        if (i + 2 < cleaned.length) buffer.write(' ');
      }
      return buffer.toString();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Résumé du Transfert',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Téléphone',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            Text(
              formatNumeroDeuxParDeux(numero),
              style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSummaryItemWithIcon(
          label: 'Catégorie',
          value: type ?? 'Non spécifié',
          icon: Icons.category,
          iconColor: Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildSummaryItemWithIcon(
          label: 'Type',
          value: subtype ?? 'Non spécifié',
          icon: Icons.layers,
          iconColor: Colors.green,
        ),
        const SizedBox(height: 8),
        _buildSummaryItemWithIcon(
          label: 'Réseau',
          value: network ?? 'Non spécifié',
          icon: Icons.network_cell,
          iconColor: Colors.purple,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Montant',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Icon(Icons.attach_money, color: Colors.blue, size: 24),
                Text(
                  'FCFA ${formatMontant(montant)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildSummaryItemWithIcon(
          label: 'Commission',
          value: 'FCFA ${formatMontant(commission)}',
          icon: Icons.money_off,
          iconColor: Colors.red,
        ),
        const SizedBox(height: 8),
        _buildSummaryItemWithIcon(
          label: 'Date',
          value: DateFormat('dd/MM/yyyy').format(date),
          icon: Icons.calendar_today,
          iconColor: Colors.teal,
        ),
        const SizedBox(height: 8),
        if (reference.isNotEmpty)
          _buildSummaryItemWithIcon(
            label: 'Référence',
            value: reference,
            icon: Icons.receipt,
            iconColor: Colors.brown,
          ),
        const SizedBox(height: 24),
        SizedBox(
          height: 45.0,
          child: buildActionButton(
            'Valider',
            Icons.save,
            onSubmit,
            isLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItemWithIcon({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              Icon(icon, color: iconColor, size: 24),
              Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
