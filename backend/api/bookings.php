<?php
// ✅ ใช้ config กลาง
require_once '../config.php';

// สร้าง visit_number: BK-2026-00001
function makeVisitNumber($conn) {
    $year = (int)date('Y');
    $s = $conn->prepare("SELECT COUNT(*) AS cnt FROM bookings WHERE YEAR(created_at)=?");
    $s->bind_param('i',$year); $s->execute();
    $seq = (int)$s->get_result()->fetch_assoc()['cnt'] + 1;
    $s->close();
    return 'BK-'.$year.'-'.str_pad($seq,5,'0',STR_PAD_LEFT);
}

$method    = $_SERVER['REQUEST_METHOD'];
$bookingId = isset($_GET['id'])      ? intval($_GET['id'])      : null;
$userId    = isset($_GET['user_id']) ? intval($_GET['user_id']) : null;

// ===== GET =====
if ($method === 'GET') {
    $joinSql = "SELECT b.id, b.visit_number,
                    b.user_id, b.vehicle_id, b.parking_lot_id, b.parking_spot_id,
                    b.start_time, b.end_time, b.total_price, b.status, b.created_at,
                    u.username      AS user_name,
                    v.license_plate AS vehicle_plate,
                    pl.name         AS lot_name,
                    ps.spot_number  AS spot_number
                FROM bookings b
                LEFT JOIN users         u  ON b.user_id         = u.id
                LEFT JOIN vehicles      v  ON b.vehicle_id      = v.id
                LEFT JOIN parking_lots  pl ON b.parking_lot_id  = pl.id
                LEFT JOIN parking_spots ps ON b.parking_spot_id = ps.id";

    if ($bookingId) {
        $s=$conn->prepare("$joinSql WHERE b.id=?");
        $s->bind_param('i',$bookingId); $s->execute(); $r=$s->get_result();
        $r->num_rows ? sendResponse($r->fetch_assoc()) : sendError('Not found',404);
    } elseif ($userId) {
        $s=$conn->prepare("$joinSql WHERE b.user_id=? ORDER BY b.created_at DESC");
        $s->bind_param('i',$userId); $s->execute();
        sendResponse($s->get_result()->fetch_all(MYSQLI_ASSOC));
    } else {
        sendResponse($conn->query("$joinSql ORDER BY b.created_at DESC")->fetch_all(MYSQLI_ASSOC));
    }
}
// ===== POST =====
elseif ($method === 'POST') {
    $raw = file_get_contents('php://input');
    $input = json_decode($raw, true);
    if (json_last_error() !== JSON_ERROR_NONE) sendError('Invalid JSON: '.json_last_error_msg(), 400);

    // ตรวจสอบตัวแปรให้ครบ
    foreach (['userId','vehicleId','parkingLotId','parkingSpotId','startTime'] as $f) {
        if (!isset($input[$f])) sendError("Missing: $f", 400);
    }

    $visitNumber = makeVisitNumber($conn);
    $uid  = intval($input['userId']);
    $vid  = intval($input['vehicleId']);
    $plid = intval($input['parkingLotId']);
    $psid = intval($input['parkingSpotId']);
    $endTime    = $input['endTime']    ?? null;
    $totalPrice = (float)($input['totalPrice'] ?? 0);
    // ถ้าไม่ส่ง status มา ให้ default เป็น 'pending'
    $status     = $input['status']     ?? 'pending';

    $s = $conn->prepare("INSERT INTO bookings
        (visit_number,user_id,vehicle_id,parking_lot_id,parking_spot_id,start_time,end_time,total_price,status)
        VALUES (?,?,?,?,?,?,?,?,?)");
    
    if (!$s) sendError('Prepare failed: '.$conn->error, 500);

    $s->bind_param('siiiissds',
        $visitNumber, $uid, $vid, $plid, $psid,
        $input['startTime'], $endTime, $totalPrice, $status);

    if ($s->execute()) {
        $newId = (int)$conn->insert_id;
        sendResponse(['id'=>$newId, 'visit_number'=>$visitNumber, 'message'=>'Booking created'], 201);
    }
    sendError('Execute failed: '.$s->error, 500);
}
// ===== PUT, DELETE เหมือนเดิม ... =====
elseif ($method === 'PUT') {
    if (!$bookingId) sendError('ID required',400);
    $input=json_decode(file_get_contents('php://input'),true);
    $tp=(float)$input['totalPrice'];
    $s=$conn->prepare("UPDATE bookings SET end_time=?,total_price=?,status=? WHERE id=?");
    $s->bind_param('sdsi',$input['endTime'],$tp,$input['status'],$bookingId);
    $s->execute() ? sendResponse(['message'=>'Updated']) : sendError('Update failed',500);
}
elseif ($method === 'DELETE') {
    if (!$bookingId) sendError('ID required',400);
    $s=$conn->prepare("DELETE FROM bookings WHERE id=?");
    $s->bind_param('i',$bookingId);
    $s->execute() ? sendResponse(['message'=>'Deleted']) : sendError('Delete failed',500);
}
else { sendError('Method not allowed',405); }
$conn->close();
?>