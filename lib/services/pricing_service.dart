// ไฟล์สำหรับคำนวณราคาจอดรถ (Pricing Service)

class PricingService {
  // ราคาต่อชั่วโมง (หลังจากชั่วโมงแรกฟรี)
  static const double pricePerHour = 50.0; // 50 บาท/ชั่วโมง

  // ค่าธรรมเนียมเพิ่มเติม (อาจจะใช้ในอนาคต)
  static const double serviceFee = 0.0; // 0 บาท

  // ฟังก์ชั่นสำหรับคำนวณราคา
  static double calculatePrice({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    // คำนวณเวลาที่จอด (หน่วยเป็นนาที)
    final duration = endTime.difference(startTime);
    final durationInMinutes = duration.inMinutes;

    // ถ้าจอดน้อยกว่า 1 ชั่วโมง ราคาเป็น 0 บาท (ชั่วโมงแรกฟรี)
    if (durationInMinutes <= 60) {
      return 0.0;
    }

    // คำนวณเวลาที่เกิน 1 ชั่วโมง
    final minutesAfterFirstHour = durationInMinutes - 60;

    // แปลงนาทีเป็นชั่วโมง (ปัดขึ้น)
    // เช่น 75 นาที = 15 นาที = 0.25 ชั่วโมง ปัดขึ้นเป็น 1 ชั่วโมง
    final hoursCharged = (minutesAfterFirstHour / 60).ceil();

    // คำนวณราคา
    final totalPrice = hoursCharged * pricePerHour + serviceFee;

    return totalPrice;
  }

  // ฟังก์ชั่นสำหรับแสดงราคาเป็นสตริง
  static String formatPrice(double price) {
    // จัดรูปแบบราคาให้แสดง 2 ตำแหน่งทศนิยม
    return '${price.toStringAsFixed(2)} บาท';
  }

  // ฟังก์ชั่นสำหรับคำนวณเวลาที่จอด
  static String calculateDuration({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    // คำนวณเวลาที่จอด
    final duration = endTime.difference(startTime);

    // ดึงจำนวนชั่วโมง นาที วินาที
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    // แสดงค่า
    if (hours == 0) {
      return '$minutes นาที';
    } else if (minutes == 0) {
      return '$hours ชั่วโมง';
    } else {
      return '$hours ชั่วโมง $minutes นาที';
    }
  }

  // ฟังก์ชั่นสำหรับตรวจสอบว่าได้จอดฟรีหรือไม่
  static bool isFreeParking({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    // ตรวจสอบว่าจอดไม่เกิน 1 ชั่วโมง
    final durationInMinutes = endTime.difference(startTime).inMinutes;
    return durationInMinutes <= 60;
  }
}
