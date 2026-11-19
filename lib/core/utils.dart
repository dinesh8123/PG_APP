import 'package:intl/intl.dart';

String monthKey(DateTime date) => DateFormat('yyyy-MM').format(date);

String prevMonthKey(DateTime date) =>
    monthKey(DateTime(date.year, date.month - 1));

String monthLabel(String key) =>
    DateFormat('MMMM yyyy').format(DateTime.parse('$key-01'));

String rupee(num value) => NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 0,
    ).format(value);

String dateLabel(DateTime date) => DateFormat('d MMM yyyy').format(date);

String longDate(DateTime date) => DateFormat('EEEE, d MMMM').format(date);

String greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();

  return (parts.first[0] + parts.last[0]).toUpperCase();
}
