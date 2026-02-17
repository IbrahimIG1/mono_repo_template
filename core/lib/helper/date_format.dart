import 'package:intl/intl.dart';

String dateLocalFormat(DateTime? utcDate) {
  if (utcDate != null) {
    return '${DateFormat('dd-MM-yyyy').format(utcDate.toLocal())} (${DateFormat('hh:mm a').format(utcDate.toLocal())})';
  } else {
    return '';
  }
}
