import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';

class DepenseGraph extends StatefulWidget {
  final String label;
  const DepenseGraph({super.key, required this.label});

  @override
  State<DepenseGraph> createState() => _DepenseGraphState();
}

class _DepenseGraphState extends State<DepenseGraph> {
  List<_DepenseData> data = [];

  @override
  void initState() {
    super.initState();
    _generateRandomData();
  }

  void _generateRandomData() {
    final Random random = Random();
    setState(() {
      data = List.generate(
        12,
        (index) => _DepenseData(
          _getMonthName(index),
          random.nextInt(50000).toDouble(),
        ),
      );
    });
  }

  String _getMonthName(int index) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ];
    return months[index];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label, style: TextStyle()),
            SizedBox(height: 16.0),
            Center(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  plotOffset: 10,
                ),
                primaryYAxis: NumericAxis(title: AxisTitle()),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  AreaSeries<_DepenseData, String>(
                    dataSource: data,
                    xValueMapper: (_DepenseData sales, _) => sales.mois,
                    yValueMapper: (_DepenseData sales, _) => sales.montant,
                    markerSettings: const MarkerSettings(isVisible: true),
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    color:
                        const Color.fromARGB(255, 210, 2, 106).withOpacity(0.5),
                    borderWidth: 2,
                    borderColor: const Color.fromARGB(255, 210, 2, 106),
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

class _DepenseData {
  final String mois;
  final double montant;

  _DepenseData(this.mois, this.montant);
}
