import 'package:intl/intl.dart';

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
