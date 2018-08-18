#!/usr/bin/env php
<?php

// Add new account to the database
require_once dirname(__FILE__) . "/config.php";
require_once dirname(__FILE__) . "/lib/include.authFunctions.php";

if (count($argv) < 4) {
	exit(usage());
}

// TODO: We don't really need to ask for the current username here, as we'll get that anyway in the call to authAccount

function usage() {
	global $argv;
	echo "Add new Minecraft account to the database.
Usage: " . $argv[0] . " <email address> <username> <password>
";
}

$db = new SQLite3(DATABASE_PATH);

// Parse the arguments

$user_info = array("email" => $argv[1], "user" => $argv[2], "pass" => $argv[3]);

// Validate email
if (!filter_var($user_info["email"], FILTER_VALIDATE_EMAIL)) {
	exit("[ERROR] That's not a valid email address.\n");
}

// Get the UUID from Mojang

$get_uuid = json_decode(file_get_contents("https://api.mojang.com/users/profiles/minecraft/" . $user_info["user"]),true);

if (!$get_uuid) {
	exit("[ERROR] Username/UUID fetch failed\n");
}
if (isset($get_uuid["id"],$get_uuid["name"])) {
	$user_info["uuid"] = $get_uuid["id"];
	$user_info["user"] = $get_uuid["name"]; // correct capitalization
} else {
        exit("[ERROR] Username/UUID fetch failed\n");
}

// Validate credentials with Mojang

$testAuth = authAccount($user_info["email"], $user_info["pass"]);

if (isset($testAuth["error"], $testAuth["errorMessage"])) {
	echo "[ERROR] Mojang returned the following error upon attempting to authenticate:\n";
	echo "        'error'		=> " . $testAuth["error"] . "\n";
	echo "        'errorMessage	=> " . $testAuth["errorMessage"] . "\n";
	exit("Maybe the credentials are wrong, or we've been ratelimited...\n");
} elseif (isset($testAuth["accessToken"], $testAuth["clientToken"], $testAuth["selectedProfile"])) {

	echo "[INFO] Confirmed login.\n";
	echo "       Username: " . $testAuth["selectedProfile"]["name"] . "\n";
	echo "           UUID: " . $testAuth["selectedProfile"]["id"]   . "\n";
	$user_info["user"]		= $testAuth["selectedProfile"]["name"];
	$user_info["uuid"]		= $testAuth["selectedProfile"]["id"];
	$user_info["access_token"]	= $testAuth["accessToken"];
	$user_info["client_token"]	= $testAuth["clientToken"];
}


// Add these to the database

$addCreds = $db->prepare("INSERT INTO accounts (account_uuid, account_email, account_password, account_username, access_token, client_token) VALUES (:uuid, :email, :pass, :user, :access, :client)");
$addCreds->bindValue(':uuid',	$user_info["uuid"], SQLITE3_TEXT);
$addCreds->bindValue(':email',	$user_info["email"], SQLITE3_TEXT);
$addCreds->bindValue(':pass',	$user_info["pass"], SQLITE3_TEXT);
$addCreds->bindValue(':user',	$user_info["user"], SQLITE3_TEXT);
$addCreds->bindValue(':access',	$user_info["access_token"], SQLITE3_TEXT);
$addCreds->bindValue(':client',	$user_info["client_token"], SQLITE3_TEXT);

$result = $addCreds->execute();

exit("[INFO] Added Minecraft account (" . $user_info["user"] ." - " . $user_info["uuid"] . ")\n");

