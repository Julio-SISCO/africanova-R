import 'dart:math';
import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/view/components/depenses/depense_chart.dart';
import 'package:africanova/view/components/depenses/detail_depense.dart';
import 'package:africanova/view/components/depenses/page_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DepensePage extends StatefulWidget {
  final Function(Widget) switchView;
  const DepensePage({super.key, required this.switchView});

  @override
  State<DepensePage> createState() => _DepensePageState();
}

class _DepensePageState extends State<DepensePage> {
  final List<String> months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
    'Total'
  ];
  List<double> values = [];
  Widget _content = Container();

  @override
  void initState() {
    super.initState();
    getValues();
    _content = _defaultContent();
  }

  void content(Widget? w) {
    setState(() {
      _content = w ?? _defaultContent();
    });
  }

  void getValues() {
    final Random random = Random();
    setState(() {
      values = List.generate(
          13, (index) => (500 + random.nextInt(100000 - 500)).toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageButton(switchView: content),
          _content,
        ],
      ),
    );
  }

  Widget _defaultContent() {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 100) / 4;
            return Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                _buildDepenseCard(
                  title: 'Dépenses Annuelles',
                  montant: 55300,
                  value: 1,
                  color: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .tertiary,
                  width: cardWidth,
                ),
                _buildDepenseCard(
                  title: 'Dépenses Fixes',
                  montant: 55300,
                  value: 0.5,
                  color: const Color.fromARGB(255, 47, 2, 210),
                  width: cardWidth,
                ),
                _buildDepenseCard(
                  title: 'Dépenses Variables',
                  montant: 55300,
                  value: 0.8,
                  color: const Color.fromARGB(255, 5, 202, 133),
                  width: cardWidth,
                ),
                _buildDepenseCard(
                  title: 'Dépenses Ocasionnelles',
                  montant: 55300,
                  value: 0.4,
                  color: const Color.fromARGB(255, 210, 2, 106),
                  width: cardWidth,
                ),
              ],
            );
          },
        ),
        DetailDepense(),
        Row(
          children: [
            Expanded(child: DepenseGraph(label: "Total des dépenses")),
            Expanded(
                child: DepenseGraph(label: "Total des dépenses par source")),
          ],
        ),
      ],
    );
  }

  Widget _buildDepenseCard({
    required String title,
    required double montant,
    required double value,
    required Color color,
    required double width,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18.0, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              formatMontant(montant),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18.0, color: color),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: width,
              child: LinearProgressIndicator(
                value: value,
                minHeight: 20.0,
                backgroundColor: Colors.grey.shade300,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
