<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$host = 'localhost';
$dbname = 'equihorizon'; // ← change ça
$user = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $rawData = file_get_contents("php://input");
    $data = json_decode($rawData);

    if (!$data) {
        echo json_encode([
            "success" => false,
            "error" => "Données JSON non valides",
            "debug_raw" => $rawData
        ]);
        exit;
    }

    $refidcours = $data->refidcours ?? null;
    $refidcava = $data->refidcava ?? null;

    if ($refidcours && $refidcava) {
        $stmt = $pdo->prepare("INSERT INTO inscrit (refidcours, refidcava) VALUES (?, ?)");
        $stmt->execute([$refidcours, $refidcava]);

        echo json_encode(["success" => true]);
    } else {
        echo json_encode([
            "success" => false,
            "error" => "Paramètres manquants",
            "refidcours" => $refidcours,
            "refidcava" => $refidcava
        ]);
    }
} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "error" => "Erreur DB: " . $e->getMessage()
    ]);
}
