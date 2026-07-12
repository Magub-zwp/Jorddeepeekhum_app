// ไฟล์สำหรับค่าคงที่ของสี, ข้อความและสไตล์ (Constants)
import 'package:flutter/material.dart';

class AppColors {
  // สีหลักของแอปพลิเคชัน (Light Theme - Figma)
  static const Color primaryBlue = Color(0xFF0038FF); // สีน้ำเงินหลักจาก Figma
  static const Color dark = Color(0xFF1E1C1C); // สีดำสำหรับข้อความ
  static const Color charcoal = Color(0xFF757575); // สีเทาเข้ม
  static const Color lightgray = Color(0xFFE0E0E0); // สีเทาอ่อนสำหรับ Border
  static const Color veryLightGray = Color(0xFFF5F6FA); // สีพื้นหลังหน้าจอ

  // สีหลัก
  static const Color primaryColor = primaryBlue;
  static const Color primaryDark = dark;
  static const Color accentColor = primaryBlue;

  // สีพื้นหลัง
  static const Color backgroundColor = veryLightGray;
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // สีข้อความ
  static const Color textPrimary = dark;
  static const Color textSecondary = charcoal;
  static const Color textHint = Color(0xFFBDBDBD);

  // สีพิเศษ
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFFF4545);
  static const Color warningColor = Color(0xFFFF9800);

  // สีสำหรับสถานะจอดรถ
  static const Color availableColor = Color(0xFFE8EAF6); // สีฟ้าระเรื่อ
  static const Color occupiedColor = Color(0xFFEEEEEE); // สีเทา
  static const Color selectedColor = primaryBlue; // สีน้ำเงินเข้ม
}

class AppStrings {
  // ข้อความสำหรับหน้า Login
  static const String login = 'เข้าสู่ระบบ';
  static const String register = 'สมัครสมาชิก';
  static const String email = 'อีเมล';
  static const String password = 'รหัสผ่าน';
  static const String phone = 'หมายเลขโทรศัพท์';
  static const String username = 'ชื่อผู้ใช้';
  static const String dontHaveAccount = 'ยังไม่มีบัญชี?';
  static const String haveAccount = 'มีบัญชีอยู่แล้ว?';

  // ข้อความสำหรับหน้า Parking Lots
  static const String selectParking = 'เลือกสถานที่จอดรถ';
  static const String availableSpots = 'ที่ว่าง';
  static const String totalSpots = 'ทั้งหมด';
  static const String rating = 'คะแนน';

  // ข้อความสำหรับหน้า Parking Spots
  static const String selectParkingSpot = 'เลือกช่องจอด';
  static const String floor = 'ชั้น';
  static const String available = 'ว่าง';
  static const String occupied = 'ไม่ว่าง';

  // ข้อความสำหรับหน้า Vehicle Details
  static const String vehicleDetails = 'รายละเอียดรถยนต์';
  static const String licensePlate = 'ทะเบียนรถ';
  static const String brand = 'ยี่ห้อ';
  static const String model = 'รุ่น';
  static const String color = 'สี';

  // ข้อความสำหรับหน้า Payment
  static const String payment = 'ชำระเงิน';
  static const String totalPrice = 'ราคารวม';
  static const String serviceFee = 'ค่าบริการ';
  static const String parkingPrice = 'ราคาจอดรถ';
  static const String pay = 'ชำระเงิน';

  // ข้อความทั่วไป
  static const String confirm = 'ยืนยัน';
  static const String cancel = 'ยกเลิก';
  static const String back = 'ย้อนกลับ';
  static const String next = 'ถัดไป';
  static const String submit = 'ส่ง';
  static const String logout = 'ออกจากระบบ';
  static const String loading = 'กำลังโหลด...';
  static const String error = 'เกิดข้อผิดพลาด';
  static const String success = 'สำเร็จ';
}

class AppStyles {
  // สไตล์ข้อความหัวข้อใหญ่
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // สไตล์ข้อความหัวข้อปานกลาง
  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // สไตล์ข้อความปกติ
  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  // สไตล์ข้อความรอง
  static const TextStyle bodyTextSmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  // สไตล์ปุ่ม
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.white, // เปลี่ยนเป็นสีขาวเพื่อให้ตัดกับปุ่มสีน้ำเงิน
  );
}

class AppDimensions {
  // padding และ margin
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // border radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;

  // ขนาดไอคอน
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
}
