import 'package:intl/intl.dart';

class AppDates {
  // CSV format (Spices Board)
  static final DateFormat csv = DateFormat('dd-MM-yyyy');

  // Database storage format (DATE ONLY)
  static final DateFormat db = DateFormat('yyyy-MM-dd');

  // UI display format
  static final DateFormat ui = DateFormat('dd MMM yyyy');
}
