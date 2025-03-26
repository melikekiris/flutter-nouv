<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

require_once "bdd_pdo.php";

$rawData = file_get_contents("php://input");

// Nettoyer les caractères parasites
$rawData = trim($rawData, '"');
$rawData = stripslashes($rawData);
$rawData = str_replace('\"', '"', $rawData);

$data = json_decode($rawData, true);

if (!isset($data["commande"])) {
    http_response_code(400);
    echo json_encode(["error" => "Commande non spécifiée"]);
    exit();
}

$commande = $data["commande"];

switch ($commande) {
    case 8:
        // Authentification
        if (!isset($data["username"]) || !isset($data["password"])) {
            http_response_code(400);
            echo json_encode(["error" => "Champs manquants"]);
            exit();
        }

        $username = $data["username"];
        $password = $data["password"];

        try {
            $stmt = $pdo->prepare("SELECT id FROM utilisateurs WHERE username = ? AND password = ?");
            $stmt->execute([$username, $password]);

            if ($row = $stmt->fetch()) {
                echo json_encode(["success" => true, "id" => $row["id"]]);
            } else {
                http_response_code(401);
                echo json_encode(["success" => false, "error" => "Identifiants incorrects"]);
            }
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(["success" => false, "error" => "Erreur serveur : " . $e->getMessage()]);
        }
        break;

    default:
        http_response_code(400);
        echo json_encode(["error" => "Commande non reconnue"]);
        break;
}
?>
