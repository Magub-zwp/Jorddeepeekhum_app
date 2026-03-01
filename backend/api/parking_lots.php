<?php
require_once '../config.php';
$method = $_SERVER['REQUEST_METHOD'];
$lotId  = isset($_GET['id']) ? intval($_GET['id']) : null;

if ($method === 'GET') {
    // ✅ เพิ่ม image ในการ SELECT
    $sql = "SELECT id, name, address, rating, total_spots, available_spots, operated_by, image FROM parking_lots";
    
    if ($lotId) {
        $s = $conn->prepare("$sql WHERE id=?");
        $s->bind_param('i', $lotId); 
        $s->execute(); 
        $r = $s->get_result();
        if ($r->num_rows) {
            $row = $r->fetch_assoc();
            // ✅ แปลง Binary Image เป็น Base64 String เพื่อส่งผ่าน JSON
            if (!empty($row['image'])) {
                $row['image'] = base64_encode($row['image']);
            } else {
                $row['image'] = ''; // ถ้าไม่มีรูป ส่งค่าว่าง
            }
            sendResponse($row);
        } else {
            sendError('Not found', 404);
        }
    } else {
        $result = $conn->query($sql);
        $rows = [];
        while ($row = $result->fetch_assoc()) {
            // ✅ แปลง Binary Image เป็น Base64 String
            if (!empty($row['image'])) {
                $row['image'] = base64_encode($row['image']);
            } else {
                $row['image'] = '';
            }
            $rows[] = $row;
        }
        sendResponse($rows);
    }
}
elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input) sendError('Invalid JSON', 400);
    
    $rating = (float)$input['rating'];
    $total = intval($input['totalSpots']);
    $avail = intval($input['availableSpots']);
    
    // หมายเหตุ: การอัปโหลดรูปผ่าน JSON ต้องส่งมาเป็น Base64 string
    // แต่ในโค้ดตัวอย่างนี้ยังไม่รองรับการรับค่า image เข้ามาบันทึก (รับแค่ข้อมูล text)
    
    $s = $conn->prepare("INSERT INTO parking_lots (name,address,rating,total_spots,available_spots,operated_by) VALUES (?,?,?,?,?,?)");
    $s->bind_param('ssdiis', $input['name'], $input['address'], $rating, $total, $avail, $input['operatedBy']);
    
    if ($s->execute()) {
        sendResponse(['id' => (int)$conn->insert_id], 201);
    }
    sendError('Insert failed: ' . $conn->error, 500);
}
elseif ($method === 'PUT') {
    if (!$lotId) sendError('ID required', 400);
    $input = json_decode(file_get_contents('php://input'), true);
    $rating = (float)$input['rating']; 
    $avail = intval($input['availableSpots']);
    
    $s = $conn->prepare("UPDATE parking_lots SET name=?, address=?, rating=?, available_spots=? WHERE id=?");
    $s->bind_param('ssdii', $input['name'], $input['address'], $rating, $avail, $lotId);
    
    $s->execute() ? sendResponse(['message' => 'Updated']) : sendError('Update failed', 500);
}
else { sendError('Method not allowed', 405); }
$conn->close();
?>