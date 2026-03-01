<?php
require_once '../config.php';
$method    = $_SERVER['REQUEST_METHOD'];
$vehicleId = isset($_GET['id'])      ? intval($_GET['id'])      : null;
$userId    = isset($_GET['user_id']) ? intval($_GET['user_id']) : null;

if ($method === 'GET') {
    if ($vehicleId) {
        $s=$conn->prepare("SELECT * FROM vehicles WHERE id=?");
        $s->bind_param('i',$vehicleId); $s->execute(); $r=$s->get_result();
        $r->num_rows ? sendResponse($r->fetch_assoc()) : sendError('Not found',404);
    } elseif ($userId) {
        $s=$conn->prepare("SELECT * FROM vehicles WHERE user_id=?");
        $s->bind_param('i',$userId); $s->execute();
        sendResponse($s->get_result()->fetch_all(MYSQLI_ASSOC));
    } else {
        sendResponse($conn->query("SELECT * FROM vehicles")->fetch_all(MYSQLI_ASSOC));
    }
}
elseif ($method === 'POST') {
    $input=json_decode(file_get_contents('php://input'),true);
    if (!$input) sendError('Invalid JSON',400);
    $uid=intval($input['userId']);
    $s=$conn->prepare("INSERT INTO vehicles (user_id,license_plate,brand,model,color) VALUES (?,?,?,?,?)");
    $s->bind_param('issss',$uid,$input['licensePlate'],$input['brand'],$input['model'],$input['color']);
    if ($s->execute()) {
        // id = AUTO_INCREMENT: 1, 2, 3 ...
        sendResponse(['id'=>(int)$conn->insert_id],201);
    }
    sendError('Insert failed: '.$conn->error,500);
}
elseif ($method === 'PUT') {
    if (!$vehicleId) sendError('ID required',400);
    $input=json_decode(file_get_contents('php://input'),true);
    $s=$conn->prepare("UPDATE vehicles SET license_plate=?,brand=?,model=?,color=? WHERE id=?");
    $s->bind_param('ssssi',$input['licensePlate'],$input['brand'],$input['model'],$input['color'],$vehicleId);
    $s->execute() ? sendResponse(['message'=>'Updated']) : sendError('Update failed',500);
}
elseif ($method === 'DELETE') {
    if (!$vehicleId) sendError('ID required',400);
    $s=$conn->prepare("DELETE FROM vehicles WHERE id=?");
    $s->bind_param('i',$vehicleId);
    $s->execute() ? sendResponse(['message'=>'Deleted']) : sendError('Delete failed',500);
}
else { sendError('Method not allowed',405); }
$conn->close();
?>
