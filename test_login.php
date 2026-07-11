<?php
$ch = curl_init('http://127.0.0.1/jorddeepeekhum/api/users.php');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode(['action'=>'login', 'email'=>'admin@parking.com', 'password'=>'admin123']));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$res = curl_exec($ch);
echo $res;
?>
