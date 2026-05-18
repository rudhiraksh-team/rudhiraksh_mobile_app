import 'package:intl/intl.dart';

/// Date Formatters
final DateFormat dateFmt = DateFormat("MMM d, yyyy");
final DateFormat timeFmt = DateFormat.jm();

/// Safe parse datetime from String
DateTime? parseDatetime(String? value) {
  if (value == null) return null;
  try {
    return DateTime.parse(value).toLocal();
  } catch (e) {
    return null;
  }
}

/// Add dummy transfusion data fallback
List<Map<String, dynamic>> getDummyTransfusionData() {
  final now = DateTime.now();
  return [
    {
      'id': '',
      'dateTime': now.add(Duration(days: 1)),
      'displayDate': dateFmt.format(now.add(Duration(days: 1))),
      'time': '',
      'status': 'upcoming',
      'reminderEnabled': false,
      'notes': '',
    },
  ];
}
