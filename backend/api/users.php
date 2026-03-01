<?php
// ✅ ใช้ config กลาง
require_once '../config.php';

// ==========================================
// Read Input
// ==========================================
$input = json_decode(file_get_contents('php://input'), true);
$action = $_GET['action'] ?? ($input['action'] ?? '');
$method = $_SERVER['REQUEST_METHOD'];
$userId = isset($_GET['id']) ? intval($_GET['id']) : null;

// ==========================================
// LOGIN
// ==========================================
if ($action === 'login' && $method === 'POST') {
    $email = $input['email'] ?? '';
    $password = $input['password'] ?? '';

    if (empty($email) || empty($password)) {
        sendError('กรุณากรอก Email และ Password', 400);
    }

    // ตรวจสอบว่า users table มี user นี้หรือไม่
    $stmt = $conn->prepare("SELECT id, username, email, phone, password_hash FROM users WHERE email = ?");
    if (!$stmt) {
        sendError("Database prepare error: " . $conn->error, 500);
    }
    
    $stmt->bind_param('s', $email);
    if (!$stmt->execute()) {
        sendError("Database execute error: " . $stmt->error, 500);
    }
    
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        sendError('ไม่พบผู้ใช้งานนี้ (Email: ' . $email . ')', 404);
    }

    $user = $result->fetch_assoc();

    // ตรวจสอบพาสเวิร์ด
    $hash_match = password_verify($password, $user['password_hash']);
    $plain_match = ($password === $user['password_hash']);

    if ($hash_match || $plain_match) {
        sendResponse([
            'id' => (int)$user['id'],
            'username' => $user['username'],
            'email' => $user['email'],
            'phone' => $user['phone'] ?? '',
            'message' => 'Login Successful'
        ], 200);
    } else {
        sendError('รหัสผ่านไม่ถูกต้อง', 401);
    }

    $stmt->close();
}
// ==========================================
// REGISTER
// ==========================================
elseif ($action === 'register' && $method === 'POST') {
    $username = $input['username'] ?? '';
    $email = $input['email'] ?? '';
    $phone = $input['phone'] ?? '';
    $password = $input['password'] ?? '';

    if (empty($username) || empty($email) || empty($password)) {
        sendError('ข้อมูลไม่ครบถ้วน: username, email, password จำเป็น', 400);
    }

    // ตรวจสอบอีเมลซ้ำ
    $check = $conn->prepare("SELECT id FROM users WHERE email = ?");
    if (!$check) {
        sendError("Database prepare error: " . $conn->error, 500);
    }
    
    $check->bind_param('s', $email);
    $check->execute();
    if ($check->get_result()->num_rows > 0) {
        sendError('อีเมลนี้ถูกใช้งานแล้ว', 400);
    }
    $check->close();

    // Hash รหัสผ่าน
    $hash = password_hash($password, PASSWORD_DEFAULT);
    
    $stmt = $conn->prepare("INSERT INTO users (username, email, phone, password_hash) VALUES (?, ?, ?, ?)");
    if (!$stmt) {
        sendError("Database prepare error: " . $conn->error, 500);
    }
    
    $stmt->bind_param('ssss', $username, $email, $phone, $hash);
    
    if ($stmt->execute()) {
        sendResponse([
            'id' => (int)$conn->insert_id,
            'username' => $username,
            'email' => $email,
            'phone' => $phone,
            'message' => 'Register Successful'
        ], 201);
    } else {
        sendError('Register Error: ' . $conn->error, 500);
    }

    $stmt->close();
}
// ==========================================
// GET USER (Single)
// ==========================================
elseif ($method === 'GET' && $userId) {
    $stmt = $conn->prepare("SELECT id, username, email, phone FROM users WHERE id = ?");
    if (!$stmt) {
        sendError("Database prepare error: " . $conn->error, 500);
    }
    
    $stmt->bind_param('i', $userId);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows === 0) {
        sendError('User not found', 404);
    }

    sendResponse($result->fetch_assoc(), 200);
    $stmt->close();
}
// ==========================================
// GET ALL USERS (Debug)
// ==========================================
elseif ($method === 'GET') {
    $result = $conn->query("SELECT id, username, email, phone FROM users");
    if (!$result) {
        sendError("Database query error: " . $conn->error, 500);
    }
    sendResponse($result->fetch_all(MYSQLI_ASSOC), 200);
}
// ==========================================
// UPDATE USER
// ==========================================
elseif ($method === 'PUT' && $userId) {
    $username = $input['username'] ?? '';
    $phone = $input['phone'] ?? '';
    
    $stmt = $conn->prepare("UPDATE users SET username = ?, phone = ? WHERE id = ?");
    if (!$stmt) {
        sendError("Database prepare error: " . $conn->error, 500);
    }
    
    $stmt->bind_param('ssi', $username, $phone, $userId);
    
    if ($stmt->execute()) {
        sendResponse(['message' => 'User updated successfully'], 200);
    } else {
        sendError('Update failed: ' . $conn->error, 500);
    }

    $stmt->close();
}
// ==========================================
// DELETE USER
// ==========================================
elseif ($method === 'DELETE' && $userId) {
    $stmt = $conn->prepare("DELETE FROM users WHERE id = ?");
    if (!$stmt) {
        sendError("Database prepare error: " . $conn->error, 500);
    }
    
    $stmt->bind_param('i', $userId);
    
    if ($stmt->execute()) {
        sendResponse(['message' => 'User deleted successfully'], 200);
    } else {
        sendError('Delete failed: ' . $conn->error, 500);
    }

    $stmt->close();
}
// ==========================================
// Method Not Allowed
// ==========================================
else {
    sendError('Invalid action or method not allowed (action=' . $action . ', method=' . $method . ')', 405);
}

$conn->close();
?>
