import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AppUtils {
  // initialize locale ครั้งเดียว
  static bool _localeInitialized = false;

  static Future<void> initLocale() async {
    if (!_localeInitialized) {
      await initializeDateFormatting('th_TH', null);
      _localeInitialized = true;
    }
  }

  // แปลง DateTime → วันที่ + เวลา เช่น 13/02/2026 14:30
  // ใช้ 'en_US' แทน 'th_TH' เพื่อหลีกเลี่ยง locale init issue
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^\d{10,}$').hasMatch(phone);
  }

  static bool isValidPassword(String password) => password.length >= 6;

  static bool isValidLicensePlate(String plate) =>
      plate.isNotEmpty && plate.length >= 4 && plate.length <= 10;

  static bool isValidInput(String input) =>
      input.isNotEmpty && input.length >= 2;
}
