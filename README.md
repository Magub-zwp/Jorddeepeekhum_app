# Jorddeepeekhum_app (Parking App)

A parking reservation app built as a classroom mini project. The booking flow is similar to selecting seats in a cinema: choose a parking location, pick an available spot from a grid, enter vehicle details, calculate the fee, and confirm the booking.

Tech stack: Flutter (mobile app) + PHP (API) + MySQL (database). The backend is designed to run locally using XAMPP or any equivalent Apache/MySQL/PHP environment.

## Features

- User registration and login
- Browse parking locations (parking lots)
- Select parking spots from a grid layout
- Store vehicle information (plate number, brand, color, etc.)
- Pricing rule: first hour free, then 50 THB per additional hour
- Booking confirmation with a generated booking reference

## Tech Stack

- Frontend: Flutter (Dart)
- Backend: PHP (REST-style endpoints)
- Database: MySQL
- Local server: XAMPP (Apache + MySQL + PHP)

## Project Structure

- `lib/` Flutter application source code (screens / models / services)
- `backend/` PHP backend and API endpoints
- `assets/` Assets used by the app

More details:
- `DEVELOPMENT_GUIDE.md`
- `SETUP_GUIDE.md`

## Quick Start

### 1) Backend Setup (PHP + MySQL)

1. Start Apache and MySQL in XAMPP.
2. Place the `backend` folder under your web root (example):
   C:\xampp\htdocs\parking_app
   You should see files such as `init_db.php`, `config.php`, and the `api/` directory.
3. Initialize the database by opening:
   http://localhost/parking_app/init_db.php
   If it returns success, the database and tables are created.

### 2) Flutter App Setup

#### Android Emulator
The project is configured to reach the host machine using `10.0.2.2`.

#### Physical Device (real phone)

1. Find your computer's local IP address (e.g., run `ipconfig` and use the IPv4 address).
2. Update `lib/services/api_service.dart`:

   // From:
   static const String baseUrl = 'http://10.0.2.2/parking_app/api';
   static const String initDbUrl = 'http://10.0.2.2/parking_app/init_db.php';

   // To:
   static const String baseUrl = 'http://<YOUR_IP>/parking_app/api';
   static const String initDbUrl = 'http://<YOUR_IP>/parking_app/init_db.php';

   Replace `<YOUR_IP>` with your computer's actual IP address.


------------------------------------------------------------------------------------------------------------------

   # Jorddeepeekhum_app (Parking App)

แอพจองที่จอดรถที่ทำเป็นโปรเจคในชั้นเรียน แนวการใช้งานประมาณเลือกที่นั่งดูหนัง: เลือกสถานที่จอดรถ เลือกช่องว่างจากตาราง กรอกข้อมูลรถ คำนวณราคา แล้วกดยืนยันการจอง

ระบบใช้ Flutter (ฝั่งแอพ) + PHP (ทำ API) + MySQL (ฐานข้อมูล) โดย backend ตั้งใจให้รันบนเครื่องผ่าน XAMPP (หรือ Apache/MySQL/PHP แบบอื่นที่เทียบเท่า)

## ฟีเจอร์หลัก

- สมัครสมาชิก / เข้าสู่ระบบ
- เลือกสถานที่จอดรถ (Parking lots)
- เลือกช่องจอดจากตาราง (Parking spots)
- บันทึกข้อมูลรถ (ทะเบียน/ยี่ห้อ/สี ฯลฯ)
- คิดราคา: ชั่วโมงแรกฟรี และชั่วโมงถัดไป 50 บาท/ชม.
- ยืนยันการจองและได้เลข Booking

## ใช้อะไรทำบ้าง

- Frontend: Flutter (Dart)
- Backend: PHP (แนว REST endpoints)
- Database: MySQL
- Local server: XAMPP (Apache + MySQL + PHP)

## โครงสร้างโปรเจค (คร่าว ๆ)

- `lib/` โค้ด Flutter (screens / models / services)
- `backend/` PHP backend และ API endpoints
- `assets/` รูป/ไฟล์ประกอบ

รายละเอียดเพิ่ม:
- `DEVELOPMENT_GUIDE.md`
- `SETUP_GUIDE.md`

## Quick Start

### 1) ตั้งค่า Backend (PHP + MySQL)

1. เปิด XAMPP แล้ว Start Apache และ MySQL
2. นำโฟลเดอร์ `backend` ไปวางไว้ใน web root (ตัวอย่าง):
   C:\xampp\htdocs\parking_app
   ภายในควรเห็นไฟล์อย่าง `init_db.php`, `config.php` และโฟลเดอร์ `api/`
3. สร้าง/ตั้งค่าฐานข้อมูลโดยเปิดลิงก์นี้ในเบราว์เซอร์:
   http://localhost/parking_app/init_db.php
   ถ้าขึ้น success แปลว่า database และ tables ถูกสร้างเรียบร้อยแล้ว

### 2) ตั้งค่า Flutter App

#### Android Emulator
โปรเจคตั้งค่าไว้ให้เรียกกลับมาที่เครื่องคอมผ่าน `10.0.2.2`

#### มือถือจริง (Physical Device)

1. หา IP ของคอม (เช่นเปิด `cmd` แล้วพิมพ์ `ipconfig` จากนั้นดู IPv4)
2. ไปแก้ไฟล์ `lib/services/api_service.dart`:

   // เดิม:
   static const String baseUrl = 'http://10.0.2.2/parking_app/api';
   static const String initDbUrl = 'http://10.0.2.2/parking_app/init_db.php';

   // เปลี่ยนเป็น:
   static const String baseUrl = 'http://<YOUR_IP>/parking_app/api';
   static const String initDbUrl = 'http://<YOUR_IP>/parking_app/init_db.php';

   แทน `<YOUR_IP>` ด้วย IP จริงของคอมคุณ
