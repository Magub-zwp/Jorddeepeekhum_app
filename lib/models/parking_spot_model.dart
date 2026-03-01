// ไฟล์สำหรับกำหนดโครงสร้างข้อมูลตำแหน่งจอดรถ (ช่อง)

class ParkingSpot {
  final int id;
  final int parkingLotId;
  final String spotNumber;
  final String floor;
  final bool isAvailable;
  final double positionX;
  final double positionY;

  ParkingSpot({
    required this.id,
    required this.parkingLotId,
    required this.spotNumber,
    required this.floor,
    required this.isAvailable,
    required this.positionX,
    required this.positionY,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parkingLotId': parkingLotId,
      'spotNumber': spotNumber,
      'floor': floor,
      'isAvailable': isAvailable ? 1 : 0,
      'positionX': positionX,
      'positionY': positionY,
    };
  }

  // ✅ FIX BUG 2: PHP ส่ง snake_case → รองรับทั้ง snake_case และ camelCase
  factory ParkingSpot.fromMap(Map<String, dynamic> map) {
    return ParkingSpot(
      id: int.parse(map['id'].toString()),
      // ✅ รองรับ parking_lot_id (จาก PHP) และ parkingLotId
      parkingLotId: int.parse(
          (map['parking_lot_id'] ?? map['parkingLotId'] ?? 0).toString()),
      // ✅ รองรับ spot_number (จาก PHP) และ spotNumber
      spotNumber:
          (map['spot_number'] ?? map['spotNumber'] ?? '').toString(),
      floor: (map['floor'] ?? '').toString(),
      // ✅ FIX: PHP ส่ง is_available ไม่ใช่ isAvailable
      isAvailable:
          (map['is_available'] ?? map['isAvailable'] ?? 1).toString() == '1',
      // ✅ FIX: PHP ส่ง position_x ไม่ใช่ positionX
      positionX: double.tryParse(
              (map['position_x'] ?? map['positionX'] ?? 0).toString()) ??
          0.0,
      // ✅ FIX: PHP ส่ง position_y ไม่ใช่ positionY
      positionY: double.tryParse(
              (map['position_y'] ?? map['positionY'] ?? 0).toString()) ??
          0.0,
    );
  }
}
