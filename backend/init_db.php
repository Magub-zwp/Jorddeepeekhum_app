<?php
// ==========================================
// CORS Headers
// ==========================================
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=utf-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// ==========================================
// Database Connection
// ==========================================
error_reporting(E_ALL);
ini_set('display_errors', 0);

function sendResponse($data, $code = 200) {
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit();
}

function sendError($message, $code = 400) {
    http_response_code($code);
    echo json_encode(['error' => $message], JSON_UNESCAPED_UNICODE);
    exit();
}

// เชื่อมต่อ MySQL โดยไม่ระบุ database ก่อน
$conn = new mysqli('localhost', 'root', '');
if ($conn->connect_error) {
    sendError("Database Connection Failed: " . $conn->connect_error, 500);
}
$conn->set_charset('utf8mb4');

// ==========================================
// สร้าง Database
// ==========================================
$dbName = 'jorddeepeekhum_db';
$createDbSql = "CREATE DATABASE IF NOT EXISTS `$dbName` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci";
if (!$conn->query($createDbSql)) {
    sendError("Failed to create database: " . $conn->error, 500);
}
print_r("✅ Database created/exists\n");

// เลือก Database
if (!$conn->select_db($dbName)) {
    sendError("Failed to select database: " . $conn->error, 500);
}

// ==========================================
// ✅ สร้างตาราง USERS
// ==========================================
$usersTableSql = "CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

if (!$conn->query($usersTableSql)) {
    sendError("Failed to create users table: " . $conn->error, 500);
}
echo "✅ users table created/exists\n";

// ==========================================
// ✅ สร้างตาราง VEHICLES
// ==========================================
$vehiclesTableSql = "CREATE TABLE IF NOT EXISTS vehicles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    color VARCHAR(30),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

if (!$conn->query($vehiclesTableSql)) {
    sendError("Failed to create vehicles table: " . $conn->error, 500);
}
echo "✅ vehicles table created/exists\n";

// ==========================================
// ✅ สร้างตาราง PARKING_LOTS
// ==========================================
$parkingLotsTableSql = "CREATE TABLE IF NOT EXISTS parking_lots (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    rating DECIMAL(3,1) DEFAULT 0.0,
    total_spots INT DEFAULT 0,
    available_spots INT DEFAULT 0,
    operated_by VARCHAR(100),
    image LONGBLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

if (!$conn->query($parkingLotsTableSql)) {
    sendError("Failed to create parking_lots table: " . $conn->error, 500);
}
echo "✅ parking_lots table created/exists\n";

// ==========================================
// ✅ สร้างตาราง PARKING_SPOTS
// ==========================================
$parkingSpotsTableSql = "CREATE TABLE IF NOT EXISTS parking_spots (
    id INT PRIMARY KEY AUTO_INCREMENT,
    parking_lot_id INT NOT NULL,
    spot_number VARCHAR(20) NOT NULL,
    floor VARCHAR(20),
    is_available TINYINT(1) DEFAULT 1,
    position_x DECIMAL(8,2) DEFAULT 0,
    position_y DECIMAL(8,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parking_lot_id) REFERENCES parking_lots(id) ON DELETE CASCADE,
    UNIQUE KEY unique_spot (parking_lot_id, spot_number),
    INDEX idx_lot_id (parking_lot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

if (!$conn->query($parkingSpotsTableSql)) {
    sendError("Failed to create parking_spots table: " . $conn->error, 500);
}
echo "✅ parking_spots table created/exists\n";

// ==========================================
// ✅ สร้างตาราง BOOKINGS
// ==========================================
$bookingsTableSql = "CREATE TABLE IF NOT EXISTS bookings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    visit_number VARCHAR(20) NOT NULL UNIQUE,
    user_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    parking_lot_id INT NOT NULL,
    parking_spot_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    total_price DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (parking_lot_id) REFERENCES parking_lots(id),
    FOREIGN KEY (parking_spot_id) REFERENCES parking_spots(id),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

if (!$conn->query($bookingsTableSql)) {
    sendError("Failed to create bookings table: " . $conn->error, 500);
}
echo "✅ bookings table created/exists\n";

// ==========================================
// ✅ สร้าง Admin User (Test Account)
// ==========================================
$adminCreated = false;
$adminEmail = 'admin@test.com';
$adminPassword = 'admin123';
$adminHash = password_hash($adminPassword, PASSWORD_DEFAULT);

// ตรวจสอบว่า admin มีอยู่แล้วหรือไม่
$checkAdmin = $conn->prepare("SELECT id FROM users WHERE email = ?");
$checkAdmin->bind_param('s', $adminEmail);
$checkAdmin->execute();
$result = $checkAdmin->get_result();

if ($result->num_rows === 0) {
    // สร้าง admin user
    $stmt = $conn->prepare("INSERT INTO users (username, email, phone, password_hash) VALUES (?, ?, ?, ?)");
    $adminUsername = 'Admin';
    $adminPhone = '0800000000';
    $stmt->bind_param('ssss', $adminUsername, $adminEmail, $adminPhone, $adminHash);
    
    if ($stmt->execute()) {
        $adminCreated = true;
        echo "✅ Admin user created\n";
    } else {
        echo "⚠️ Admin user already exists\n";
    }
    $stmt->close();
} else {
    echo "⚠️ Admin user already exists\n";
}
$checkAdmin->close();

// ==========================================
// ✅ ตอบกลับ Response
// ==========================================
$response = [
    'success' => true,
    'message' => 'Database initialization completed successfully!',
    'database' => $dbName,
    'tables_created' => [
        'users',
        'vehicles',
        'parking_lots',
        'parking_spots',
        'bookings'
    ],
    'admin' => [
        'created' => $adminCreated,
        'email' => $adminEmail,
        'password' => $adminPassword,
        'note' => '⚠️ อย่าลืมเปลี่ยนรหัสผ่านหลังจากเข้าระบบ!'
    ]
];

$conn->close();
sendResponse($response, 200);
?>
