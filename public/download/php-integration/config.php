<?php
/**
 * Konfigurasi Ronipaygate
 * Ganti nilai-nilai di bawah dengan punya kamu.
 */

// API Ronipaygate
define('RPG_API_URL', 'http://localhost:3000');
define('RPG_API_KEY', 'gb_live_xxxxxxxxxxxxx');
define('RPG_WEBHOOK_SECRET', 'whsec_xxxxxxxxxx');

// Database MySQL
define('DB_HOST', 'localhost');
define('DB_NAME', 'tokoku');
define('DB_USER', 'root');
define('DB_PASS', '');

// Base URL toko kamu
define('APP_URL', 'https://tokoku.com');

// ═══ Helper ═══

function db() {
    static $pdo;
    if (!$pdo) {
        $pdo = new PDO(
            'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
            DB_USER, DB_PASS
        );
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    }
    return $pdo;
}

function writeLog($file, $msg) {
    file_put_contents($file, '[' . date('Y-m-d H:i:s') . '] ' . $msg . "\n", FILE_APPEND);
}

function apiPost($url, $body, $apiKey) {
    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_POST           => true,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT        => 30,
        CURLOPT_HTTPHEADER     => [
            'X-API-Key: ' . $apiKey,
            'Content-Type: application/json',
        ],
        CURLOPT_POSTFIELDS     => json_encode($body),
    ]);
    $res = curl_exec($ch);
    curl_close($ch);
    return json_decode($res, true);
}
