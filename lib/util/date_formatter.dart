import 'package:africanova/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

String formatDate(DateTime? date) {
  if (date == null) return '';

  final now = DateTime.now();
  final difference = now.difference(date);
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(Duration(days: 1));
  final formattedDate = DateTime(date.year, date.month, date.day);

  if (difference.inMinutes < 1) {
    return 'À l\'instant';
  } else if (formattedDate == today) {
    return 'Aujourd\'hui à ${hour}h $minute';
  } else if (formattedDate == yesterday) {
    return 'Hier à ${hour}h $minute';
  } else {
    return '${DateFormat('dd MMMM yyyy', 'fr').format(date)} à ${hour}h $minute';
  }
}

String formatDateRange(DateTime start, DateTime end) {
  final dateFormat = DateFormat('d MMMM yyyy', 'fr_FR');
  final monthFormat = DateFormat('MMMM yyyy', 'fr_FR');
  final dayFormat = DateFormat('d MMMM yyyy', 'fr_FR');
  final weekDayFormat = DateFormat('d', 'fr_FR');

  if (start.isAtSameMomentAs(end)) {
    return 'Journée du ${dayFormat.format(start)}';
  }

  if (start.year == end.year &&
      start.month == end.month &&
      start.day == 1 &&
      end.day == DateTime(start.year, start.month + 1, 0).day) {
    return 'Mois de ${monthFormat.format(start)}';
  }

  if (start.weekday == DateTime.monday &&
      end.weekday == DateTime.sunday &&
      end.difference(start).inDays == 6) {
    return 'Semaine${end.difference(start).inDays > 6 ? 's' : ''} du ${weekDayFormat.format(start)} au ${dateFormat.format(end)}';
  }

  return 'Période du ${dateFormat.format(start)} au ${dateFormat.format(end)}';
}

String formatMontant(double montant) {
  final formatter = NumberFormat("#,##0", "en_US");
  return formatter.format(montant);
}

Future<DateTime?> selecteDate(DateTime initialDate, BuildContext context) async {
  final date = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
    locale: const Locale('fr', 'FR'),
    builder: (context, child) {
      return Theme(
        data: Provider.of<ThemeProvider>(context).themeData.copyWith(
              primaryColor: Color(0xFF056148),
              hintColor: Color(0xFF056148),
              colorScheme: Provider.of<ThemeProvider>(context).isLightTheme()
                  ? ColorScheme.light(
                      primary: Color(0xFF056148),
                      onPrimary: Colors.white,
                    )
                  : ColorScheme.dark(
                      primary: Color(0xFF056148),
                      onPrimary: Colors.white,
                    ),
            ),
        child: child!,
      );
    },
  );
  return date;
}


Widget buildDatePicker({
  required DateTime initialDate,
  required ValueChanged<DateTime> onDateChanged,
}) {
  return StatefulBuilder(
    builder: (context, setLocalState) {
      String text = DateFormat('dd MMMM yyyy', 'fr').format(initialDate);

      return InkWell(
        onTap: () async {
          DateTime? picked = await selecteDate(initialDate, context);
          if (picked != null) {
            onDateChanged(picked);
            setLocalState(() {
              text = DateFormat('dd MMMM yyyy', 'fr').format(picked);
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
              const Icon(Icons.calendar_today, size: 18),
            ],
          ),
        ),
      );
    },
  );
}
