import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/vehicle_model.dart';
import '../models/parking_lot_model.dart';
import '../models/parking_spot_model.dart';
import '../models/booking_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1/jorddeepeekhum/api';
  static const String initDbUrl = 'http://127.0.0.1/jorddeepeekhum/init_db.php';

  // Singleton Pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ===== ฐานข้อมูล (DATABASE INIT) =====
  Future<void> initializeDatabase() async {
    try {
      print('[DB] กำลังเริ่มต้นฐานข้อมูล...');
      final response = await http
          .get(Uri.parse(initDbUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('[DB] สำเร็จ: ${data['message']}');
          if (data['admin'] != null && data['admin']['created'] == true) {
            print('[DB] สร้าง Admin - อีเมล: ${data['admin']['email']} / รหัสผ่าน: ${data['admin']['password']}');
          }
        }
      }
    } catch (e) {
      print('[ERROR] ล้มเหลว: $e');
      print('[HINT] ตรวจสอบว่า Apache/MySQL ทำงานอยู่');
    }
  }

  // ===== ผู้ใช้ (USERS) =====
  Future<User> registerUser(
      String username, String email, String phone, String password) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/users.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'action': 'register',
            'username': username,
            'email': email,
            'phone': phone,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return User(
        id: (data['id'] as num).toInt(),
        username: data['username'] ?? username,
        email: data['email'] ?? email,
        phone: phone,
        password: password,
      );
    }
    final err = json.decode(response.body);
    throw Exception(err['error'] ?? 'สมัครสมาชิกล้มเหลว');
  }

  // เข้าสู่ระบบ (LOGIN)
  Future<User> loginUser(String email, String password) async {
    try {
      print('[LOGIN] กำลังเข้าสู่ระบบ: $email');
      
      final response = await http
          .post(
            Uri.parse('$baseUrl/users.php'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'action': 'login',
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('[RESPONSE] สถานะ: ${response.statusCode}');
      print('[RESPONSE] ข้อมูล: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);
          
          if (data['id'] == null) {
          throw Exception('API ส่งค่า id = null');
        }
        
        return User(
          id: (data['id'] as num).toInt(),
          username: data['username'] ?? '',
          email: data['email'] ?? email,
          phone: data['phone'] ?? '',
          password: '',
        );
      }
      
      print('[ERROR] สถานะโปรแกรม: ${response.statusCode}');
      final err = json.decode(response.body);
      throw Exception(err['error'] ?? 'เข้าสู่ระบบล้มเหลว (สถานะ ${response.statusCode})');
    } catch (e) {
      print('[EXCEPTION] $e');
      rethrow;
    }
  }

  // ===== รถยนต์ (VEHICLES) =====
  Future<int> insertVehicle(Vehicle vehicle) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/vehicles.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userId': vehicle.userId,
            'licensePlate': vehicle.licensePlate,
            'brand': vehicle.brand,
            'model': vehicle.model,
            'color': vehicle.color,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final newId = (data['id'] as num).toInt();
      print('[VEHICLE] บันทึกสำเร็จ id=$newId');
      return newId;
    }
    final err = json.decode(response.body);
    throw Exception(err['error'] ?? 'ไม่สามารถบันทึกรถยนต์');
  }

  Future<List<Vehicle>> getVehiclesByUserId(int userId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/vehicles.php?user_id=$userId'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => Vehicle.fromMap(j)).toList();
    }
    return [];
  }

  // ===== สถานที่จอดรถ (PARKING LOTS) =====
  Future<void> insertParkingLot(ParkingLot lot) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/parking_lots.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': lot.name,
            'address': lot.address,
            'image': lot.image,
            'rating': lot.rating,
            'totalSpots': lot.totalSpots,
            'availableSpots': lot.availableSpots,
            'operatedBy': lot.operatedBy,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 201) {
      final err = json.decode(response.body);
      throw Exception(err['error'] ?? 'ไม่สามารถเพิ่มสถานที่จอดรถ');
    }
  }

  Future<List<ParkingLot>> getAllParkingLots() async {
    final response = await http
        .get(Uri.parse('$baseUrl/parking_lots.php'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('[PARKING_LOTS] ได้รับ ${data.length} สถานที่');
      return data.map((j) => ParkingLot.fromMap(j)).toList();
    }
    return [];
  }

  // ===== ช่องจอดรถ (PARKING SPOTS) =====
  Future<void> insertParkingSpot(ParkingSpot spot) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/parking_spots.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'parkingLotId': spot.parkingLotId,
            'spotNumber': spot.spotNumber,
            'floor': spot.floor,
            'isAvailable': spot.isAvailable ? 1 : 0,
            'positionX': spot.positionX,
            'positionY': spot.positionY,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 201) {
      final err = json.decode(response.body);
      throw Exception(err['error'] ?? 'ไม่สามารถเพิ่มช่องจอดรถ');
    }
  }

  Future<List<ParkingSpot>> getParkingSpotsByLotId(int lotId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/parking_spots.php?lot_id=$lotId'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => ParkingSpot.fromMap(j)).toList();
    }
    return [];
  }

  Future<void> updateParkingSpotAvailability(
      int spotId, bool isAvailable) async {
    await http
        .put(
          Uri.parse('$baseUrl/parking_spots.php?id=$spotId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'isAvailable': isAvailable ? 1 : 0}),
        )
        .timeout(const Duration(seconds: 10));
  }

  // ===== การจอดรถ (BOOKINGS) =====
  Future<Map<String, dynamic>> insertBooking(Booking booking) async {
    print('[BOOKING] กำลังสร้างการจอดรถ...');

    final response = await http
        .post(
          Uri.parse('$baseUrl/bookings.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userId': booking.userId,
            'vehicleId': booking.vehicleId,
            'parkingLotId': booking.parkingLotId,
            'parkingSpotId': booking.parkingSpotId,
            'startTime': booking.startTime.toIso8601String(),
            'endTime': booking.endTime?.toIso8601String(),
            'totalPrice': booking.totalPrice,
            'status': booking.status,
          }),
        )
        .timeout(const Duration(seconds: 10));

    print('[RESPONSE] สถานะ: ${response.statusCode}');
    print('[RESPONSE] ข้อมูล: ${response.body}');

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final bookingId = (data['id'] as num).toInt();
      final visitNumber = data['visit_number'] as String;
      print('[BOOKING] สำเร็จ id=$bookingId เลข=$visitNumber');
      return {
        'id': bookingId,
        'visit_number': visitNumber,
      };
    }

    final err = json.decode(response.body);
    throw Exception(err['error'] ?? 'ไม่สามารถสร้างการจอดรถ');
  }

  Future<List<Booking>> getBookingsByUserId(int userId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/bookings.php?user_id=$userId'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => Booking.fromMap(j)).toList();
    }
    return [];
  }
}
