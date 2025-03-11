import 'package:africanova/database/service.dart';
import 'package:africanova/database/vente.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final double y;
}

class PieChartData {
  final String x; // Nom de la catégorie
  final double y; // Valeur
  final String label; // Label pour les légendes ou les data labels

  PieChartData(this.x, this.y, this.label);
}


double getMaxValue(List<ChartData> data) {
  if (data.isEmpty) return 0;
  return data.map((e) => e.y).reduce((a, b) => a > b ? a : b);
}

double getInterval(double maxValue) {
  return (maxValue / 5).ceilToDouble();
}

Future<Map<String, double>> generateSalesStatistics(int monthsBack) async {
  var box = Hive.box<Vente>('venteHistory');
  List<Vente> ventes = box.values.toList();

  Map<String, double> statistics = {};

  DateTime now = DateTime.now();
  for (int i = 0; i < monthsBack; i++) {
    DateTime month = DateTime(now.year, now.month - i, 1);
    String monthYear = DateFormat('MMMM yyyy', 'fr_FR').format(month);
    statistics[monthYear] = 0.0;
  }

  for (var vente in ventes) {
    String monthYear =
        DateFormat('MMMM yyyy', 'fr_FR').format(vente.createdAt!);
    if (statistics.containsKey(monthYear)) {
      statistics[monthYear] =
          (statistics[monthYear] ?? 0) + vente.montantTotal;
    }
  }

  return Map.fromEntries(statistics.entries.toList());
}

Future<Map<String, double>> generateServicesStatistics(int monthsBack) async {
  var box = Hive.box<Service>('serviceBox');
  List<Service> services = box.values.toList();

  Map<String, double> statistics = {};

  DateTime now = DateTime.now();
  for (int i = 0; i < monthsBack; i++) {
    DateTime month = DateTime(now.year, now.month - i, 1);
    String monthYear = DateFormat('MMMM yyyy', 'fr_FR').format(month);
    statistics[monthYear] = 0.0;
  }

  for (var service in services) {
    String monthYear =
        DateFormat('MMMM yyyy', 'fr_FR').format(service.createdAt);
    if (statistics.containsKey(monthYear)) {
      statistics[monthYear] =
          (statistics[monthYear] ?? 0) + (service.total ?? 0);
    }
  }

  return Map.fromEntries(statistics.entries.toList());
}

Future<List<ChartData>> buildSaleData(int recentMonths) async {
  Map<String, double> statistics = await generateSalesStatistics(recentMonths);

  List<ChartData> data = statistics.entries.map((entry) {
    return ChartData(entry.key, entry.value);
  }).toList();

  return data;
}

Future<List<ChartData>> buildServiceData(int recentMonths) async {
  Map<String, double> statistics = await generateServicesStatistics(recentMonths);

  List<ChartData> data = statistics.entries.map((entry) {
    return ChartData(entry.key, entry.value);
  }).toList();

  return data;
}
Future<List<ChartData>> buildPieSaleData(int recentMonths) async {
  Map<String, double> statistics = await generateSalesStatistics(recentMonths);

  List<ChartData> data = statistics.entries.map((entry) {
    return ChartData(entry.key, entry.value);
  }).toList();

  return data;
}

Future<List<ChartData>> buildPieServiceData(int recentMonths) async {
  Map<String, double> statistics = await generateServicesStatistics(recentMonths);

  List<ChartData> data = statistics.entries.map((entry) {
    return ChartData(entry.key, entry.value);
  }).toList();

  return data;
}
