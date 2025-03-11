import 'dart:math';

import 'package:africanova/provider/charts_provider.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ServiceChart extends StatefulWidget {
  const ServiceChart({super.key});

  @override
  State<ServiceChart> createState() => _ServiceChartState();
}

class _ServiceChartState extends State<ServiceChart> {
  late List<ChartData> dataSale;
  late List<ChartData> dataService;
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
    return SizedBox(
      height: MediaQuery.of(context).size.width * 0.35,
      child: Card(
        color: Colors.blueGrey[200],
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: _buildBarChart(context),
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final maxValue = max(getMaxValue(dataSale), getMaxValue(dataService));

    return Column(
      children: [
        Expanded(
          child: SfCartesianChart(
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
                color: Colors.white,
              ),
              ColumnSeries<ChartData, String>(
                dataSource: dataService,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                name: 'Total des services',
                color: Colors.amber[700],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
