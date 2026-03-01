# 🚗 แอพจองที่จอดรถ (Parking App)

## 📝 อธิบายโครงการ
นี่คือแอพพลิเคชันสำหรับจองที่จอดรถแบบเรียบง่าย ที่จำลองลักษณะการจองตั๋วในโรงหนัง เช่น Major Cineplex หรือ SF Cineplex

## 🎯 คุณลักษณะหลัก
1. **ระบบเข้าสู่ระบบและสมัครสมาชิก** - ลงทะเบียนและเข้าสู่ระบบ
2. **เลือกสถานที่จอดรถ** - ดูสถานที่จอดรถที่มีอยู่
3. **เลือกช่องจอด** - เลือกช่องจอดที่ต้องการ
4. **กรอกข้อมูลรถ** - ป้อนทะเบียนรถ ยี่ห้อ สี เป็นต้น
5. **คำนวณราคา** - ตามตรรมชาติ ชั่วโมงแรกฟรี ชั่วโมงต่อไป 50 บาท/ชม.
6. **ชำระเงิน** - ดำเนินการชำระเงินและบันทึก

---

## 📁 โครงสร้างแฟ้ม

```
lib/
├── main.dart                      # ไฟล์หลักของแอป
│
├── models/                        # โมเดลข้อมูล
│   ├── user_model.dart            # โมเดล User
│   ├── parking_lot_model.dart     # โมเดล ParkingLot
│   ├── parking_spot_model.dart    # โมเดล ParkingSpot
│   ├── vehicle_model.dart         # โมเดล Vehicle
│   └── booking_model.dart         # โมเดล Booking
│
├── services/                      # บริการ (Logic)
│   ├── database_service.dart      # ฐานข้อมูล
│   ├── auth_service.dart          # การเข้าสู่ระบบ
│   └── pricing_service.dart       # คำนวณราคา
│
├── screens/                       # หน้าต่างๆ
│   ├── login_screen.dart          # หน้าเข้าสู่ระบบ
│   ├── register_screen.dart       # หน้าสมัครสมาชิก
│   ├── parking_lots_screen.dart   # หน้าเลือกสถานที่
│   ├── parking_spots_screen.dart  # หน้าเลือกช่องจอด
│   ├── vehicle_details_screen.dart # หน้าข้อมูลรถ
│   ├── payment_screen.dart        # หน้าชำระเงิน
│   ├── booking_confirmation_screen.dart  # หน้ายืนยัน
│   └── booking_history_screen.dart       # หน้าประวัติ (ในอนาคต)
│
├── utils/                         # ฟังก์ชั่นช่วยเหลือ
│   ├── app_constants.dart         # ค่าคงที่ สี ข้อความ
│   └── app_utils.dart             # ฟังก์ชั่นช่วยเหลือ
└── pubspec.yaml                   # Dependencies
```

---

## 🔧 ไลบรารี่ที่ใช้

| ชื่อ | เวอร์ชั่น | ใช้งาน |
|------|---------|--------|
| **sqflite** | ^2.2.8+4 | ฐานข้อมูล (SQLite) |
| **uuid** | ^4.0.0 | สร้าง Unique ID |
| **intl** | ^0.19.0 | จัดรูปแบบวันที่เวลา |
| **provider** | ^6.1.5+1 | State Management (อนาคต) |
| **http** | ^1.6.0 | API Calls (อนาคต) |

---

## 📱 ขั้นตอนการใช้แอป

1. **สมัครสมาชิก** → ป้อน ชื่อ อีเมล เบอร์โทร รหัสผ่าน
2. **เข้าสู่ระบบ** → ป้อน อีเมล รหัสผ่าน
3. **เลือกสถานที่** → ดูรายการสถานที่
4. **เลือกช่องจอด** → เลือกจากกริด
5. **กรอกรถ** → ทะเบียน ยี่ห้อ รุ่น สี (สามารถใช้รถที่บันทึกไว้)
6. **ตรวจสอบราคา** → ดูสรุปการจอด
7. **ชำระเงิน** → บันทึก Booking ในฐานข้อมูล
8. **การยืนยัน** → ดูหมายเลข Booking

---

## 💾 ฐานข้อมูล

### ตาราง Users
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  username TEXT,
  email TEXT,
  phone TEXT,
  password TEXT
)
```

### ตาราง Vehicles
```sql
CREATE TABLE vehicles (
  id TEXT PRIMARY KEY,
  userId TEXT,
  licensePlate TEXT,
  brand TEXT,
  model TEXT,
  color TEXT
)
```

### ตาราง Parking_Lots
```sql
CREATE TABLE parking_lots (
  id TEXT PRIMARY KEY,
  name TEXT,
  address TEXT,
  image TEXT,
  rating REAL,
  totalSpots INTEGER,
  availableSpots INTEGER,
  operatedBy TEXT
)
```

### ตาราง Parking_Spots
```sql
CREATE TABLE parking_spots (
  id TEXT PRIMARY KEY,
  parkingLotId TEXT,
  spotNumber TEXT,
  floor TEXT,
  isAvailable INTEGER,
  positionX REAL,
  positionY REAL
)
```

### ตาราง Bookings
```sql
CREATE TABLE bookings (
  id TEXT PRIMARY KEY,
  userId TEXT,
  parkingLotId TEXT,
  parkingSpotId TEXT,
  vehicleId TEXT,
  startTime TEXT,
  endTime TEXT,
  totalPrice REAL,
  status TEXT
)
```

---

## 🧮 ตรรมชาติคำนวณราคา

```
ชั่วโมงแรก → 0 บาท (ฟรี)
ชั่วโมงถัดไป → 50 บาท/ชม.

ตัวอย่าง:
- จอด 30 นาที → 0 บาท
- จอด 1 ชั่วโมง → 0 บาท
- จอด 2 ชั่วโมง → 50 บาท
- จอด 3.5 ชั่วโมง → 150 บาท (ปัดขึ้น)
```

---

## 🎨 ตัวแปรสีและสไตล์

### สีหลัก
- **Primary** - ฟ้า (#1976D2)
- **Success** - เขียว (#4CAF50)
- **Error** - แดง (#F44336)
- **Warning** - ส้ม (#FF9800)

### สถานะจอดรถ
- ✅ ว่าง - สีเขียว
- ❌ ไม่ว่าง - สีแดง
- 🔵 เลือก - สีฟ้า

---

## 🚀 วิธีเรียกใช้

1. **ติดตั้ง Dependencies**
   ```bash
   flutter pub get
   ```

2. **รันแอป**
   ```bash
   flutter run
   ```

3. **สร้าง APK/IPA**
   ```bash
   # APK (Android)
   flutter build apk --release
   
   # IPA (iOS)
   flutter build ipa --release
   ```

---

## 📝 โค้ดตัวอย่าง - การเพิ่มรถใหม่

```dart
// สร้าง Vehicle object
final vehicle = Vehicle(
  id: const Uuid().v4(),
  userId: authService.currentUser!.id,
  licensePlate: 'บท 1234 กรุงเทพ',
  brand: 'Toyota',
  model: 'Camry',
  color: 'ขาว',
);

// บันทึกลงฐานข้อมูล
await databaseService.insertVehicle(vehicle);
```

---

## 📚 โค้ดตัวอย่าง - คำนวณราคา

```dart
// คำนวณราคา
final price = PricingService.calculatePrice(
  startTime: DateTime(2024, 5, 31, 10, 0),
  endTime: DateTime(2024, 5, 31, 13, 30),
);

// จะได้ 100 บาท (2.5 ชั่วโมง = 2 ชั่วโมง @ 50 บาท = 100)
```

---

## ⚠️ หมายเหตุสำคัญ

1. **ข้อมูลตัวอย่าง** - ข้อมูลตัวอย่างจะเพิ่มอัตโนมัติเมื่อเปิดแอปครั้งแรก
2. **รหัสผ่าน** - ในแอปจริง ต้อง Hash รหัสผ่าน (ใช้ bcrypt หรือ Argon2)
3. **API จริง** - ช่วงนี้ใช้ข้อมูลในเครื่องเท่านั้น
4. **Payment Gateway** - ยังไม่เชื่อมต่อกับระบบชำระเงินจริง
5. **Validation** - ควรเพิ่ม validation เพิ่มเติมสำหรับความปลอดภัย

---

## 🎓 การเรียนรู้และการขยาย

### การเพิ่มคุณลักษณะใหม่:
1. **Notification** - แจ้งเตือนเมื่อใกล้หมดเวลา
2. **Map Integration** - แสดงตำแหน่งสถานที่บนแผนที่
3. **Payment Gateway** - เชื่อมต่อ Stripe, 2C2P เป็นต้น
4. **QR Code** - สร้าง QR Code สำหรับทดเลนรถ
5. **Rating & Review** - ให้ผู้ใช้ให้คะแนนสถานที่

### สิ่งที่ต้องปรับปรุง:
1. กำหนดเส้นทาง Guard เพื่อตรวจสอบการเข้าสู่ระบบ
2. ใช้ Provider สำหรับ State Management
3. เพิ่ม Input Validation อย่างละเอียด
4. เพิ่ม Error Handling
5. เพิ่ม Unit Tests और Integration Tests

---

## 💡 คำแนะนำ

- ทำความเข้าใจ **Dart** และ **Flutter** ก่อน
- อ่านความเห็น (`//`) ในโค้ด เพื่อเข้าใจการทำงาน
- แบ่งงานเป็นหน้า (Screens) ตามโฟลว์
- ทดสอบแต่ละหน้าแยกกันก่อน
- ใช้ **StatefulWidget** สำหรับหน้าที่มี State
- ใช้ **StatelessWidget** สำหรับหน้าแบบคงที่

---

## 📞 การติดต่อและการสนับสนุน

หากมีข้อสงสัยหรือพบปัญหา โปรดติดต่อทีมพัฒนาซอฟต์แวร์

---

## 📄 เอกสารอ้างอิง

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language](https://dart.dev/guides)
- [SQLite Package](https://pub.dev/packages/sqflite)
- [UUID Package](https://pub.dev/packages/uuid)

---

**สร้างเมื่อ:** 2024 | **ภาษา:** Dart + Flutter | **ประเทศ:** ไทย 🇹🇭
