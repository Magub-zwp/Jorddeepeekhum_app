# Parking App - Setup Guide

## Requirements
- XAMPP (or similar: Apache + MySQL + PHP)
- Flutter SDK
- Android/iOS Emulator or Physical Device

## Step 1: Setup PHP Backend

### 1.1 Start XAMPP Services
```
1. Open XAMPP Control Panel
2. Start Apache ✓
3. Start MySQL ✓
```

### 1.2 Verify PHP Server is Running
```
Open browser: http://localhost/
Should show XAMPP dashboard
```

### 1.3 Place Backend Files
```
Copy the 'backend' folder to:
C:\xampp\htdocs\parking_app

Final path should be:
  C:\xampp\htdocs\parking_app\
  ├── config.php
  ├── init_db.php
  ├── .htaccess
  └── api/
      ├── users.php
      ├── vehicles.php
      ├── parking_lots.php
      ├── parking_spots.php
      └── bookings.php
```

### 1.4 Verify Backend is Accessible
```
Open browser:
- http://localhost/parking_app/init_db.php

Should see JSON response like:
{
  "success": true,
  "message": "Database and tables have been set up successfully!"
}
```

## Step 2: Get Your Computer IP Address

### On Windows (for Physical Devices):
```
Open Command Prompt and run:
ipconfig

Look for "IPv4 Address" under your WiFi connection
Example: 192.168.1.100
```

## Step 3: Setup Flutter App

### 3.1 For Android Emulator:
The app is already configured to use `10.0.2.2` which is the special address 
for Android Emulator to access host machine's localhost.

### 3.2 For Physical Device:
Edit `lib/services/api_service.dart` and change:
```dart
// From:
static const String baseUrl = 'http://10.0.2.2/parking_app/api';
static const String initDbUrl = 'http://10.0.2.2/parking_app/init_db.php';

// To (replace 192.168.1.100 with your IP):
static const String baseUrl = 'http://192.168.1.100/parking_app/api';
static const String initDbUrl = 'http://192.168.1.100/parking_app/init_db.php';
```

## Step 4: Run the Flutter App

```bash
# Connect device or start emulator first

# Run the app flutter run

# Or with specific device
flutter run -d <device-id>
```

## Step 5: Login

When the app starts, it will:
1. Connect to init_db.php
2. Create database `parking_app_db`
3. Create all tables
4. Create admin user

**Default Admin Account:**
```
Email: admin@parking.app
Password: admin
```

## Troubleshooting

### ❌ "Cannot connect to API" or "Connection refused"

**Problem**: PHP server not running or unreachable
**Solution**:
1. Verify XAMPP Apache is running
2. Check http://localhost/parking_app/init_db.php in browser
3. Restart Apache if using physical device

### ❌ "Database initialization failed"

**Problem**: MySQL not running
**Solution**:
1. Start MySQL in XAMPP Control Panel
2. Verify MySQL service is running
3. Check MySQL credentials in backend/config.php

### ❌ "Database connection failed"

**Problem**: Wrong database credentials
**Solution**:
1. Check backend/config.php:
   - DB_HOST: localhost
   - DB_USER: root
   - DB_PASS: (usually empty)
2. Verify MySQL user 'root' exists

### ❌ App runs but "Cannot load parking lots"

**Problem**: API calls failing
**Solution**:
1. Check if using correct IP address for physical device
2. Ensure both device and computer are on same WiFi
3. Check Windows Firewall isn't blocking port 80

### ❌ "Admin user not created"

**Problem**: User creation failed, but database exists
**Solution**:
1. Try login with admin/admin anyway
2. If fails, manually create user via MySQL:
```sql
INSERT INTO users (id, username, email, phone, password_hash) 
VALUES (
  UUID(), 
  'admin', 
  'admin@parking.app', 
  '0800000000', 
  '$2y$10$...' -- bcrypt hash of 'admin'
);
```

## Testing Database

### Check if database was created:
```bash
# In Command Prompt
mysql -u root -p

# Leave password empty, just press Enter

# In MySQL shell:
SHOW DATABASES;
USE parking_app_db;
SHOW TABLES;
SELECT * FROM users;
```

## Important Notes

1. **Port 80 Firewall**: Ensure Windows Firewall allows Apache on port 80
2. **Magic IP Address**: 
   - Android Emulator: 10.0.2.2
   - iOS Simulator: localhost or 127.0.0.1
   - Physical Device: Your computer's IP address
3. **Database Auto-Creation**: The app will automatically create database on first run
4. **Admin Auto-Creation**: Admin user will be created automatically if database is created

## Next Steps

1. Run the app
2. You should see database creation logs in Flutter console
3. Login with: admin@parking.app / admin
4. Add parking lots and test the app
