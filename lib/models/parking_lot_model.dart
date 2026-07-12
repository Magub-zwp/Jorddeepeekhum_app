// ไฟล์สำหรับกำหนดโครงสร้างข้อมูลสถานที่จอดรถ

class ParkingLot {
  final int id;
  final String name;
  final String address;
  final String image;
  final double rating;
  final int totalSpots;
  final int availableSpots;
  final String operatedBy;
  final double latitude;
  final double longitude;

  ParkingLot({
    required this.id,
    required this.name,
    required this.address,
    required this.image,
    required this.rating,
    required this.totalSpots,
    required this.availableSpots,
    required this.operatedBy,
    this.latitude = 13.7563, // Default BKK Lat
    this.longitude = 100.5018, // Default BKK Lng
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'image': image,
      'rating': rating,
      'totalSpots': totalSpots,
      'availableSpots': availableSpots,
      'operatedBy': operatedBy,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // ✅ FIX BUG 1: PHP ส่งมา snake_case → รองรับทั้ง snake_case และ camelCase
  factory ParkingLot.fromMap(Map<String, dynamic> map) {
    return ParkingLot(
      id: int.parse(map['id'].toString()),
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      image: map['image'] ?? '',
      rating: double.tryParse(map['rating']?.toString() ?? '0') ?? 0.0,
      // ✅ รองรับ total_spots (จาก PHP) และ totalSpots (camelCase)
      totalSpots: int.tryParse(
              (map['total_spots'] ?? map['totalSpots'])?.toString() ?? '0') ??
          0,
      // ✅ รองรับ available_spots (จาก PHP) และ availableSpots
      availableSpots: int.tryParse(
              (map['available_spots'] ?? map['availableSpots'])?.toString() ??
                  '0') ??
          0,
      // ✅ รองรับ operated_by (จาก PHP) และ operatedBy
      operatedBy:
          (map['operated_by'] ?? map['operatedBy'] ?? '').toString(),
      latitude: double.tryParse(map['latitude']?.toString() ?? '13.7563') ?? 13.7563,
      longitude: double.tryParse(map['longitude']?.toString() ?? '100.5018') ?? 100.5018,
    );
  }
}
