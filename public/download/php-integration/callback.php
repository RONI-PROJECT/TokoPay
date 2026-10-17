<?php
/**
 * Callback — terima webhook dari Ronipaygate
 */
require 'config.php';

$logFile = __DIR__ . '/webhook.log';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit('Method not allowed');
}

$rawBody   = file_get_contents('php://input');
$signature = $_SERVER['HTTP_X_SIGNATURE'] ?? '';

writeLog($logFile, '--- Webhook received ---');
writeLog($logFile, 'Body: ' . $rawBody);

// Verifikasi signature
$expected = 'sha256=' . hash_hmac('sha256', $rawBody, RPG_WEBHOOK_SECRET);

if (!hash_equals($expected, $signature)) {
    writeLog($logFile, 'INVALID signature!');
    http_response_code(401);
    echo json_encode(['ok' => false, 'error' => 'Invalid signature']);
    exit;
}

writeLog($logFile, 'Signature VALID');

$data = json_decode($rawBody, true);
if (!$data) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => 'Invalid JSON']);
    exit;
}

$event = $data['event'] ?? '';
$trxId = $data['trxId'] ?? '';

writeLog($logFile, "Event: $event | TrxID: $trxId");

try {
    if ($event === 'payment.paid') {
        handlePaid($trxId, $logFile);
    } elseif ($event === 'payment.expired') {
        handleExpired($trxId, $logFile);
    }

    http_response_code(200);
    echo json_encode(['ok' => true, 'received' => true]);

} catch (Exception $e) {
    writeLog($logFile, 'Error: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => $e->getMessage()]);
}

function handlePaid($trxId, $logFile) {
    $stmt = db()->prepare('SELECT status FROM orders WHERE trx_id = ?');
    $stmt->execute([$trxId]);
    $order = $stmt->fetch();

    if (!$order) {
        writeLog($logFile, "Order $trxId tidak ditemukan");
        return;
    }
    if ($order['status'] === 'paid') {
        writeLog($logFile, "Order $trxId sudah PAID, skip");
        return;
    }

    $stmt = db()->prepare('UPDATE orders SET status = "paid", paid_at = NOW() WHERE trx_id = ?');
    $stmt->execute([$trxId]);
    writeLog($logFile, "Order $trxId updated to PAID");
}

function handleExpired($trxId, $logFile) {
    $stmt = db()->prepare('UPDATE orders SET status = "expired" WHERE trx_id = ? AND status = "pending"');
    $stmt->execute([$trxId]);
    writeLog($logFile, "Order $trxId updated to EXPIRED");
}
