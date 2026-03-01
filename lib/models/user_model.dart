// ไฟล์สำหรับกำหนดโครงสร้างข้อมูลของผู้ใช้งาน

class User {
  final int id;
  final String username;
  final String email;
  final String phone;
  final String password;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    this.password = '', // ✅ FIX BUG 7: ไม่ required เพราะ API ไม่ส่ง password กลับ
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }

  // ✅ FIX BUG 7: API ไม่ส่ง password กลับมา ต้องรองรับ null
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: int.parse(map['id'].toString()),
      username: (map['username'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      password: (map['password'] ?? '').toString(), // ✅ ไม่ crash ถ้าไม่มี
    );
  }
}
