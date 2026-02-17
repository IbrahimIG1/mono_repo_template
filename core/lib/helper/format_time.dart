import 'package:intl/intl.dart';

String formatTimeHelper(String isoString) {
  final date = DateTime.tryParse(isoString);
  if (date == null) return '';
  // Format as hour:minute with Arabic AM/PM
  final formatted = DateFormat('h:mm a', 'ar').format(date);
  // Replace AM/PM with Arabic symbols if needed
  return formatted.replaceAll('AM', 'ص').replaceAll('PM', 'م');
}
