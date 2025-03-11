// ignore_for_file: deprecated_member_use

import 'package:africanova/theme/theme_provider.dart';
import 'package:africanova/util/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MoreHeader extends StatefulWidget {
  final Function(DateTime, DateTime) setValues;
  final Function(String) setPeriod;
  final VoidCallback printTable;
  const MoreHeader({
    super.key,
    required this.setValues,
    required this.setPeriod,
    required this.printTable,
  });

  @override
  State<MoreHeader> createState() => _MoreHeaderState();
}

class _MoreHeaderState extends State<MoreHeader> {
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

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
    bool isDateFilterValid =
        _startDate.isBefore(_endDate) || _startDate.isAtSameMomentAs(_endDate);

    if (isDateFilterValid) {
      widget.setPeriod(
        formatDateRange(
          _startDate,
          _endDate,
        ),
      );
      widget.setValues(
        _startDate,
        _endDate,
      );
    }
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      elevation: 0.0,
      backgroundColor:
          Provider.of<ThemeProvider>(context).themeData.colorScheme.primary,
      foregroundColor:
          Provider.of<ThemeProvider>(context).themeData.colorScheme.tertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Tooltip(
              message: "Exporter en pdf",
              child: TextButton.icon(
                onPressed: widget.printTable,
                style: _buttonStyle(),
                icon: Icon(
                  Icons.print,
                  color: Provider.of<ThemeProvider>(context)
                      .themeData
                      .colorScheme
                      .tertiary,
                ),
                label: const Text(
                  "Imprimer",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Wrap(
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
                SizedBox(width: 16.0),
                Tooltip(
                  message: "Appliquer le filtre",
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
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
                ),
              ],
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
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
