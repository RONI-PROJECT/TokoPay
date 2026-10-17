<?php
/**
 * Checkout — user klik "Bayar"
 */
require 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit('Method not allowed');
}

$orderId = 'ORD-' . time() . '-' . rand(1000, 9999);
$amount  = (int) ($_POST['amount'] ?? 0);
$email   = $_POST['email'] ?? '';

if ($amount < 1000) exit('Minimal Rp 1.000');

try {
    // 1. Simpan order
    $stmt = db()->prepare('
        INSERT INTO orders (order_id, amount, status, customer_email)
        VALUES (?, ?, "pending", ?)
    ');
    $stmt->execute([$orderId, $amount, $email]);

    // 2. Panggil API Ronipaygate
    $res = apiPost(RPG_API_URL . '/payment/create', [
        'amount'      => $amount,
        'callbackUrl' => APP_URL . '/callback.php',
        'metadata'    => ['orderId' => $orderId],
    ], RPG_API_KEY);

    if (empty($res['success'])) {
        exit('API Error: ' . ($res['error'] ?? 'unknown'));
    }

    $data = $res['data'];

    // 3. Simpan trxId
    $stmt = db()->prepare('UPDATE orders SET trx_id = ? WHERE order_id = ?');
    $stmt->execute([$data['trxId'], $orderId]);

    // 4. Redirect ke halaman pembayaran
    header('Location: ' . $data['paymentUrl']);
    exit;

} catch (Exception $e) {
    http_response_code(500);
    exit('Error: ' . $e->getMessage());
}
