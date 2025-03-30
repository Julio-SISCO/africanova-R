import 'dart:math';

import 'package:africanova/provider/charts_provider.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ServiceVenteChart extends StatefulWidget {
  const ServiceVenteChart({super.key});

  @override
  State<ServiceVenteChart> createState() => _ServiceVenteChartState();
}

class _ServiceVenteChartState extends State<ServiceVenteChart> {
  List<ChartData> dataSale = [];
  List<ChartData> dataService = [];
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    super.initState();
    loadData();
    _tooltip = TooltipBehavior(enable: true);
  }

  Future<void> loadData() async {
    final data0 = await buildSaleData(12);
    final data1 = await buildServiceData(12);
    setState(() {
      dataSale = data0.reversed.toList();
      dataService = data1.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double totalWidth = constraints.maxWidth;
      return SizedBox(
        height: totalWidth * 0.8,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          color:
              Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
          child: Padding(
            padding: EdgeInsets.all(0.0),
            child: dataSale.isEmpty || dataService.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      color: Provider.of<ThemeProvider>(context)
                          .themeData
                          .colorScheme
                          .secondary,
                    ),
                  )
                : _buildBarChart(context),
          ),
        ),
      );
    });
  }

  Widget _buildBarChart(BuildContext context) {
    final maxValue = max(getMaxValue(dataSale), getMaxValue(dataService));

    return Column(
      children: [
        Expanded(
          child: maxValue <= 0
              ? Center(child: Text('Aucune activité'))
              : SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: maxValue + getInterval(maxValue),
                    interval: getInterval(maxValue),
                  ),
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.top,
                    alignment: ChartAlignment.center,
                    overflowMode: LegendItemOverflowMode.scroll,
                  ),
                  tooltipBehavior: _tooltip,
                  series: <CartesianSeries<ChartData, String>>[
                    ColumnSeries<ChartData, String>(
                      dataSource: dataSale,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      name: 'Total des ventes',
                      color: const Color.fromARGB(255, 47, 2, 210),
                    ),
                    ColumnSeries<ChartData, String>(
                      dataSource: dataService,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      name: 'Total des services',
                      color: const Color.fromARGB(255, 5, 202, 133),
                    ),
                    ColumnSeries<ChartData, String>(
                      dataSource: dataSale,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) =>
                          (data.y + getInterval(maxValue)),
                      name: 'Total des dépenses',
                      color: const Color.fromARGB(255, 210, 2, 106),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
