// Booking Model - ใช้ int id + เพิ่ม visit_number
class Booking {
  final int id;              // เปลี่ยนเป็น int (1, 2, 3...)
  final String visitNumber;  // เพิ่ม visit number (BK-2026-00001)
  final int userId;          // เปลี่ยนเป็น int
  final int vehicleId;       // เปลี่ยนเป็น int
  final int parkingLotId;    // เปลี่ยนเป็น int
  final int parkingSpotId;   // เปลี่ยนเป็น int
  final DateTime startTime;
  final DateTime? endTime;
  final double totalPrice;
  final String status;

  Booking({
    required this.id,
    required this.visitNumber,
    required this.userId,
    required this.vehicleId,
    required this.parkingLotId,
    required this.parkingSpotId,
    required this.startTime,
    this.endTime,
    required this.totalPrice,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'visitNumber': visitNumber,
      'userId': userId,
      'vehicleId': vehicleId,
      'parkingLotId': parkingLotId,
      'parkingSpotId': parkingSpotId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      visitNumber: map['visit_number'] as String? ?? '',
      userId: map['user_id'] is int ? map['user_id'] : int.parse(map['user_id'].toString()),
      vehicleId: map['vehicle_id'] is int ? map['vehicle_id'] : int.parse(map['vehicle_id'].toString()),
      parkingLotId: map['parking_lot_id'] is int ? map['parking_lot_id'] : int.parse(map['parking_lot_id'].toString()),
      parkingSpotId: map['parking_spot_id'] is int ? map['parking_spot_id'] : int.parse(map['parking_spot_id'].toString()),
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time'] as String) : null,
      totalPrice: double.parse(map['total_price']?.toString() ?? '0.0'),
      status: map['status'] as String,
    );
  }

  Booking copyWith({
    int? id,
    String? visitNumber,
    int? userId,
    int? vehicleId,
    int? parkingLotId,
    int? parkingSpotId,
    DateTime? startTime,
    DateTime? endTime,
    double? totalPrice,
    String? status,
  }) {
    return Booking(
      id: id ?? this.id,
      visitNumber: visitNumber ?? this.visitNumber,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      parkingLotId: parkingLotId ?? this.parkingLotId,
      parkingSpotId: parkingSpotId ?? this.parkingSpotId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
    );
  }
}
