// ไฟล์สำหรับกำหนดโครงสร้างข้อมูลรถยนต์ของผู้ใช้

class Vehicle {
  // เก็บข้อมูลรถยนต์ของผู้ใช้
  final int id; // รหัสรถ
  final int userId; // รหัสผู้ใช้ที่เป็นเจ้าของ
  final String licensePlate; // ทะเบียนรถ
  final String brand; // ยี่ห้อรถ (เช่น Toyota, Honda)
  final String model; // รุ่นรถ (เช่น Camry, Accord)
  final String color; // สีรถ

  // Constructor สำหรับสร้าง object Vehicle
  Vehicle({
    required this.id,
    required this.userId,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.color,
  });

  // แปลง Vehicle เป็น Map สำหรับเก็บในฐานข้อมูล
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'licensePlate': licensePlate,
      'brand': brand,
      'model': model,
      'color': color,
    };
  }

  // สร้าง Vehicle object จาก Map ที่ได้จากฐานข้อมูล
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: int.parse(map['id'].toString()),
      userId: int.parse(map['user_id']?.toString() ?? map['userId'].toString()), // รองรับทั้ง user_id และ userId
      licensePlate: map['licensePlate'] ?? map['license_plate'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      color: map['color'] ?? '',
    );
  }
}
