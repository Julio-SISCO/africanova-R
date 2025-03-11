import 'package:africanova/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class StockFilters extends StatefulWidget {
  final PlutoGridStateManager? stateManager;
  final Function(String?, String?, int?, DateTime, DateTime) setValues;
  const StockFilters({super.key, required this.setValues, this.stateManager});

  @override
  State<StockFilters> createState() => _StockFiltersState();
}

class _StockFiltersState extends State<StockFilters> {
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();

  String? _selectedCriterion;
  String? _selectedCondition;
  TextEditingController valueController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  PlutoGridSelectingMode gridSelectingMode = PlutoGridSelectingMode.row;

  final List<String> _criteria = [
    'quantite initiale',
    'quantite finale esperable',
    'total debite',
    'total approvision',
    'quantite actuelle',
  ];

  final List<String> _conditions = [
    'inférieur à',
    'supérieur à',
    'inférieur ou égale à',
    'supérieur ou égale à',
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Provider.of<ThemeProvider>(context).themeData.copyWith(
                primaryColor: Colors.deepPurple,
                hintColor: Colors.deepPurple,
                colorScheme: Provider.of<ThemeProvider>(context).isLightTheme()
                    ? ColorScheme.light(
                        primary: Colors.deepPurple,
                        onPrimary: Colors.white,
                      )
                    : ColorScheme.dark(
                        primary: Colors.deepPurple,
                        onPrimary: Colors.white,
                      ),
              ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  void _applyFilters() async {
    bool isNumericFilterValid = _selectedCriterion != null &&
        _selectedCondition != null &&
        _numberController.text.isNotEmpty;

    bool isDateFilterValid = _startDate.isBefore(_endDate);

    if (isNumericFilterValid || isDateFilterValid) {
      int? value = int.tryParse(_numberController.text);

      widget.setValues(
        _selectedCriterion,
        _selectedCondition,
        value,
        _startDate,
        _endDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 8.0, bottom: 0.0, left: 5.5, right: 5.5),
      child: ExpansionTile(
        iconColor:
            Provider.of<ThemeProvider>(context).themeData.colorScheme.tertiary,
        collapsedIconColor:
            Provider.of<ThemeProvider>(context).themeData.colorScheme.tertiary,
        backgroundColor:
            Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
        collapsedBackgroundColor:
            Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
        leading: Icon(Icons.filter_alt),
        shape: Border.all(style: BorderStyle.none),
        initiallyExpanded: false,
        tilePadding: EdgeInsets.symmetric(horizontal: 8.0),
        childrenPadding: EdgeInsets.symmetric(horizontal: .0),
        trailing: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(16.0),
            elevation: 0.0,
            backgroundColor: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .secondary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          icon: Icon(Icons.filter_alt),
          onPressed: () {
            _applyFilters();
          },
          label: const Text(
            'Filtrer',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          'Filtre',
          style: TextStyle(
            color: Provider.of<ThemeProvider>(context)
                .themeData
                .colorScheme
                .tertiary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Provider.of<ThemeProvider>(context)
                  .themeData
                  .colorScheme
                  .primary
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Wrap(
                    children: [
                      _buildDateFilter(
                        context,
                        "Début",
                        _startDate,
                        () => _selectDate(context, true),
                      ),
                      SizedBox(width: 16.0),
                      _buildDateFilter(
                        context,
                        "Fin",
                        _endDate,
                        () => _selectDate(context, false),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double totalWidth = constraints.maxWidth;
                      return Wrap(
                        spacing: 8.0,
                        children: [
                          SizedBox(
                            width: (totalWidth - 16) / 3,
                            child: DropdownButtonFormField<String>(
                              value: _selectedCriterion,
                              icon: Icon(
                                Icons.arrow_drop_down_circle_sharp,
                                color: Provider.of<ThemeProvider>(context)
                                    .themeData
                                    .colorScheme
                                    .secondary,
                              ),
                              dropdownColor: Provider.of<ThemeProvider>(context)
                                  .themeData
                                  .colorScheme
                                  .primary,
                              decoration: InputDecoration(
                                labelText: "Critère",
                                prefixIcon: Icon(Icons.label),
                                border: OutlineInputBorder(),
                              ),
                              items: _criteria.map((String criterion) {
                                return DropdownMenuItem<String>(
                                  value: criterion,
                                  child: SizedBox(
                                    width: (totalWidth - 16) / 3 - 76,
                                    child: Text(
                                      criterion,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCriterion = newValue;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: (totalWidth - 16) / 3,
                            child: DropdownButtonFormField<String>(
                              padding: EdgeInsets.all(0.0),
                              value: _selectedCondition,
                              icon: Icon(
                                Icons.arrow_drop_down_circle_sharp,
                                color: Provider.of<ThemeProvider>(context)
                                    .themeData
                                    .colorScheme
                                    .secondary,
                              ),
                              dropdownColor: Provider.of<ThemeProvider>(context)
                                  .themeData
                                  .colorScheme
                                  .primary,
                              decoration: InputDecoration(
                                labelText: "Condition",
                                prefixIcon: Icon(
                                  Icons.code,
                                ),
                                border: OutlineInputBorder(),
                              ),
                              items: _conditions.map((String condition) {
                                return DropdownMenuItem<String>(
                                  value: condition,
                                  child: Text(condition),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCondition = newValue;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: (totalWidth - 16) / 3,
                            child: TextFormField(
                              controller: _numberController,
                              cursorColor: Provider.of<ThemeProvider>(context)
                                  .themeData
                                  .colorScheme
                                  .tertiary,
                              style: TextStyle(
                                color: Provider.of<ThemeProvider>(context)
                                    .themeData
                                    .colorScheme
                                    .tertiary,
                              ),
                              decoration: InputDecoration(
                                labelText: "Valeur",
                                labelStyle: TextStyle(
                                  color: Provider.of<ThemeProvider>(context)
                                      .themeData
                                      .colorScheme
                                      .tertiary,
                                ),
                                hintStyle: TextStyle(
                                  color: Provider.of<ThemeProvider>(context)
                                      .themeData
                                      .colorScheme
                                      .tertiary,
                                ),
                                prefixIcon: Icon(
                                  Icons.onetwothree,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Provider.of<ThemeProvider>(context)
                                        .themeData
                                        .colorScheme
                                        .tertiary,
                                  ),
                                ),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter(
    BuildContext context,
    String label,
    DateTime date,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd MMMM yyyy', 'fr').format(date),
              style: const TextStyle(fontSize: 14),
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }
}
