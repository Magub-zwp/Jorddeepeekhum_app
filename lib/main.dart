import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/register_screen.dart';
import 'screens/parking_lots_screen.dart';
import 'screens/parking_spots_screen.dart';
import 'screens/vehicle_details_screen.dart';
import 'screens/time_selection_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/booking_confirmation_screen.dart';
import 'screens/booking_history_screen.dart'; // ✅ เพิ่ม Import นี้
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'utils/app_constants.dart';
import 'utils/app_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await FlutterConfig.loadEnvVariables();
  } catch (e) {
    print('⚠️ Could not load .env file: $e');
  }

  await AppUtils.initLocale();

  // init database
  final apiService = ApiService();
  // await apiService.initializeDatabase(); // ❌ ปิดการรัน init_db.php เพื่อป้องกันการลบฐานข้อมูลทิ้งทุกครั้งที่เปิดแอป

  runApp(const ParkingApp());
}

class ParkingApp extends StatelessWidget {
  const ParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JordDeePeeKhum',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryBlue,
          secondary: AppColors.charcoal,
          surface: AppColors.surfaceColor,
          background: AppColors.backgroundColor,
          error: AppColors.errorColor,
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          onSurface: AppColors.textPrimary,
          onBackground: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceColor,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            borderSide: const BorderSide(color: AppColors.lightgray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            borderSide: const BorderSide(color: AppColors.lightgray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.charcoal),
          hintStyle: const TextStyle(color: AppColors.textHint),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
        ),
        cardColor: AppColors.surfaceColor,
      ),
      home: const _HomeWrapper(),
      routes: {
        '/login':                (context) => const LoginScreen(),
        '/register':             (context) => const RegisterScreen(),
        '/otp':                  (context) => const OtpScreen(),
        '/parking-lots':         (context) => const ParkingLotsScreen(),
        '/parking-spots':        (context) => const ParkingSpotsScreen(),
        '/vehicle-details':      (context) => const VehicleDetailsScreen(),
        '/time-selection':       (context) => const TimeSelectionScreen(),
        '/payment':              (context) => const PaymentScreen(),
        '/booking-confirmation': (context) => const BookingConfirmationScreen(),
        '/booking-history':      (context) => const BookingHistoryScreen(), // ✅ เพิ่ม Route ประวัติการจอด
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class _HomeWrapper extends StatelessWidget {
  const _HomeWrapper();

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    // ✅ แก้ไขตรงนี้: ลบ () ออก เพราะ isLoggedIn เป็น getter
    return authService.isLoggedIn
        ? const ParkingLotsScreen()
        : const LoginScreen();
  }
}