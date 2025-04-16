import 'dart:math';
import 'package:africanova/database/categorie_depense.dart';
import 'package:africanova/database/type_depense.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:africanova/widget/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DetailDepense extends StatefulWidget {
  const DetailDepense({super.key});

  @override
  State<DetailDepense> createState() => _DetailDepenseState();
}

class _DetailDepenseState extends State<DetailDepense> {
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
    'DEC'
  ];

  List<CategorieDepense> sources = [];
  TypeDepense? _selectedTypeDepense;
  List<TypeDepense> typeDepenses = [];
  late Map<CategorieDepense, List<double>> depenseData;
  late List<double> totalParSource;
  late List<double> totalParMois;
  late double totalGeneral;

  final Random random = Random();

  @override
  void initState() {
    super.initState();
    typeDepenses = Hive.box<TypeDepense>('typeDepenseBox').values.toList();
    sources = Hive.box<CategorieDepense>('categorieDepenseBox').values.toList();
    _generateRandomData();
  }

  void _generateRandomData() {
    depenseData = {};
    totalParSource = List.generate(sources.length, (index) => 0);
    totalParMois = List.generate(12, (index) => 0);
    totalGeneral = 0;

    for (var source in sources) {
      List<double> values = List.generate(
          12, (index) => (500 + random.nextInt(100000 - 500).toDouble()));
      depenseData[source] = values;

      for (int i = 0; i < 12; i++) {
        totalParMois[i] += values[i];
        totalParSource[sources.indexOf(source)] += values[i];
        totalGeneral += values[i];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 300,
              child: buildDropdown<TypeDepense>(
                "Type de dépenses",
                typeDepenses,
                _selectedTypeDepense,
                null,
                false,
                (value) {
                  setState(() {
                    _selectedTypeDepense = value;
                  });
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: DataTable(
                    border: TableBorder(
                        horizontalInside: BorderSide(
                            color: Color.fromARGB(255, 5, 202, 133))),
                    columnSpacing: 30,
                    headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14.0),
                    dataTextStyle: const TextStyle(fontSize: 14.0),
                    columns: [
                      const DataColumn(
                          label: Text(
                            "Source",
                            style: TextStyle(
                              color: Color.fromARGB(255, 5, 202, 133),
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                            ),
                          ),
                          numeric: false),
                      ...months.map(
                        (month) => DataColumn(
                          headingRowAlignment: MainAxisAlignment.center,
                          label: Wrap(
                            spacing: 2.0,
                            children: [
                              Text(month),
                              InkWell(
                                onTap: () {},
                                child: Icon(
                                  Icons.open_in_new,
                                  size: 10.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const DataColumn(
                        headingRowAlignment: MainAxisAlignment.center,
                        label: Text("Total"),
                      ),
                    ],
                    rows: [
                      for (var source in sources)
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                source.nom,
                                style: TextStyle(
                                  color: Color.fromARGB(255, 5, 202, 133),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                            ...depenseData[source]!.map(
                              (value) => DataCell(
                                Center(
                                  child: Text(
                                    formatMontant(value),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Text(
                                  formatMontant(
                                      totalParSource[sources.indexOf(source)]),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              "Total",
                              style: TextStyle(
                                color: Color.fromARGB(255, 5, 202, 133),
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                          ...totalParMois.map(
                            (total) => DataCell(
                              Center(
                                child: Text(
                                  formatMontant(total),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 4.0),
                                color: Color.fromARGB(255, 5, 202, 133)
                                    .withOpacity(0.4),
                                child: Text(
                                  formatMontant(totalGeneral),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
