<?php
require_once '../config.php';
$method = $_SERVER['REQUEST_METHOD'];
$spotId = isset($_GET['id'])     ? intval($_GET['id'])     : null;
$lotId  = isset($_GET['lot_id']) ? intval($_GET['lot_id']) : null;

if ($method === 'GET') {
    if ($spotId) {
        $s=$conn->prepare("SELECT * FROM parking_spots WHERE id=?");
        $s->bind_param('i',$spotId); $s->execute(); $r=$s->get_result();
        $r->num_rows ? sendResponse($r->fetch_assoc()) : sendError('Not found',404);
    } elseif ($lotId) {
        $s=$conn->prepare("SELECT * FROM parking_spots WHERE parking_lot_id=? ORDER BY spot_number");
        $s->bind_param('i',$lotId); $s->execute();
        sendResponse($s->get_result()->fetch_all(MYSQLI_ASSOC));
    } else {
        sendResponse($conn->query("SELECT * FROM parking_spots")->fetch_all(MYSQLI_ASSOC));
    }
}
elseif ($method === 'POST') {
    $input=json_decode(file_get_contents('php://input'),true);
    if (!$input) sendError('Invalid JSON',400);
    $lid=intval($input['parkingLotId']);
    $avail=intval($input['isAvailable']??1);
    $px=(float)($input['positionX']??0);
    $py=(float)($input['positionY']??0);
    $s=$conn->prepare("INSERT INTO parking_spots (parking_lot_id,spot_number,floor,is_available,position_x,position_y) VALUES (?,?,?,?,?,?)");
    $s->bind_param('issidd',$lid,$input['spotNumber'],$input['floor'],$avail,$px,$py);
    if ($s->execute()) {
        sendResponse(['id'=>(int)$conn->insert_id],201);
    }
    sendError('Insert failed: '.$conn->error,500);
}
elseif ($method === 'PUT') {
    if (!$spotId) sendError('ID required',400);
    $input=json_decode(file_get_contents('php://input'),true);
    $avail=intval($input['isAvailable']);
    $s=$conn->prepare("UPDATE parking_spots SET is_available=? WHERE id=?");
    $s->bind_param('ii',$avail,$spotId);
    $s->execute() ? sendResponse(['message'=>'Updated']) : sendError('Update failed',500);
}
else { sendError('Method not allowed',405); }
$conn->close();
?>
