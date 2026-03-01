import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
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

  // FIX: initialize locale ก่อนทุกอย่าง
  await AppUtils.initLocale();

  // init database
  final apiService = ApiService();
  await apiService.initializeDatabase();

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
        brightness: Brightness.dark,
        primaryColor: AppColors.coralred,
        scaffoldBackgroundColor: AppColors.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.coralred,
          secondary: AppColors.lightgray,
          surface: AppColors.charcoal,
          background: AppColors.dark,
          error: AppColors.coralred,
          onPrimary: AppColors.dark,
          onSecondary: AppColors.dark,
          onSurface: AppColors.textPrimary,
          onBackground: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.charcoal,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.coralred,
            foregroundColor: AppColors.dark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color.fromARGB(255, 156, 155, 155),
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
            borderSide: const BorderSide(color: AppColors.coralred, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.lightgray),
          hintStyle: const TextStyle(color: AppColors.charcoal),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.coralred),
        ),
        cardColor: AppColors.charcoal,
      ),
      home: const _HomeWrapper(),
      routes: {
        '/login':                (context) => const LoginScreen(),
        '/register':             (context) => const RegisterScreen(),
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