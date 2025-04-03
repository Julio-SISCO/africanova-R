import 'package:africanova/controller/image_url_controller.dart';
import 'package:africanova/database/top_articles.dart';
import 'package:africanova/provider/charts_provider.dart';
import 'package:africanova/theme/theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ArticlePlusVendu extends StatefulWidget {
  const ArticlePlusVendu({super.key});

  @override
  State<ArticlePlusVendu> createState() => _ArticlePlusVenduState();
}

class _ArticlePlusVenduState extends State<ArticlePlusVendu> {
  late TooltipBehavior _tooltip;
  List<TopArticles> tops = [];

  @override
  void initState() {
    super.initState();
    _tooltip = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<TopArticles>>(
      valueListenable: Hive.box<TopArticles>("topArticlesBox").listenable(),
      builder: (context, box, _) {
        final topArticles = box.values.toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            double totalWidth = constraints.maxWidth;
            return SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: totalWidth * 0.8,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      color: Provider.of<ThemeProvider>(context)
                          .themeData
                          .colorScheme
                          .primary,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Articles les plus vendus",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            _buildPieChart(context, topArticles),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      ...List.generate(topArticles.length, (index) {
                        return _buildArticleCard(topArticles[index]);
                      })
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPieChart(BuildContext context, List<TopArticles> topArticles) {
    return Expanded(
      child: SfCircularChart(
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          alignment: ChartAlignment.center,
          overflowMode: LegendItemOverflowMode.wrap,
          orientation: LegendItemOrientation.vertical,
        ),
        tooltipBehavior: _tooltip,
        series: <CircularSeries>[
          PieSeries<PieChartData, String>(
            dataSource: topArticles
                .map((top) => PieChartData(
                    top.article.libelle ?? "",
                    (top.totalQuantiteVente + top.totalQuantiteIntervention)
                        .toDouble(),
                    'Total'))
                .toList(),
            xValueMapper: (PieChartData data, _) => data.x,
            yValueMapper: (PieChartData data, _) => data.y,
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            explode: true,
            explodeIndex: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(TopArticles top) {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            double totalWidth = constraints.maxWidth;
            return Container(
              constraints: BoxConstraints(
                minHeight: totalWidth * 0.2,
              ),
              width: totalWidth / 2,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                color: Provider.of<ThemeProvider>(context)
                    .themeData
                    .colorScheme
                    .primary,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        top.article.libelle ?? "Article",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Wrap(
                        spacing: 8.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart_outlined,
                            size: 40,
                            color: Colors.blue.withOpacity(0.4),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Tooltip(
                                message: "${top.totalMontantVente}F",
                                child: Text(
                                  "${top.totalQuantiteVente} unités en vente",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 3.0),
                              Tooltip(
                                message: "${top.totalMontantService}F",
                                child: Text(
                                  "${top.totalQuantiteIntervention} unités en service",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Tooltip(
                        message:
                            "${top.totalMontantVente + top.totalMontantService}F",
                        child: Wrap(
                          spacing: 8.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(
                              Icons.monetization_on_outlined,
                              size: 40,
                              color: Colors.amber.withOpacity(0.4),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${top.pourcentageVente.toStringAsFixed(2)}% des Ventes",
                                  style: TextStyle(
                                    color: Colors.amber[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 3.0),
                                Text(
                                  "${top.pourcentageServices.toStringAsFixed(2)}% des Services",
                                  style: TextStyle(
                                    color: Colors.amber[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          top: 8.0,
          right: 8.0,
          child: (top.article.images != null && top.article.images!.isNotEmpty)
              ? CachedNetworkImage(
                  imageUrl: buildUrl(top.article.images![0].path),
                  height: 40,
                  width: 40,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => LinearProgressIndicator(
                    color: Colors.grey.withOpacity(.2),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              : Image.asset(
                  'assets/images/no_image.png',
                  height: 30,
                  width: 30,
                  fit: BoxFit.fill,
                ),
        ),
      ],
    );
  }
}
