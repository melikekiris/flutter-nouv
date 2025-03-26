<?php
function bdd() {
    $db = "mysql:host=localhost;dbname=equihorizon";
    $user = "root";
    $pass = "";
    $con = new PDO($db, $user, $pass);
    return $con;
}
?>
