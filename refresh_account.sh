#!/usr/bin/env php
<?php

// Check if current access token/client token is usable, and if not, obtain a new one

require_once dirname(__FILE__) . "/config.php";
require_once dirname(__FILE__) . "/lib/include.authFunctions.php";

if (count($argv) < 2) {
	exit(usage());
}

// TODO: We don't really need to ask for the current username here, as we'll get that anyway in the call to authAccount

function usage() {
	global $argv;
	echo "Check if current access token/client token is usable, and if not, obtain a new one
Usage: " . $argv[0] . " <email address or username>
";
}

$db = new SQLite3(DATABASE_PATH);

// Parse the arguments

$user_info = array("email_or_username" => $argv[1]);

// Validate email
$inputType = (filter_var($user_info["email_or_username"], FILTER_VALIDATE_EMAIL)) ? "email" : "username";
if ($inputType == "email") {
	// It's an email address.
	$userData = $db->query("SELECT * from accounts where account_email = '" . $db->escapeString($user_info["email_or_username"]) . "'");
	if (!$userData) { // db error
		exit("[ERROR] DB query failed: " . $db->lastErrorMsg() . "\n");
	}
	$userData = $userData->fetchArray(SQLITE3_ASSOC);
	if (!$userData) { // no user
		exit("[ERROR] No user matching that email address.\n");
	}

	// Otherwise...
} else {

	// A username
	$userData = $db->query("SELECT * from accounts where account_username = '" . $db->escapeString($user_info["email_or_username"]) . "'");
	if (!$userData) { // db error
		exit("[ERROR] DB query failed: " . $db->lastErrorMsg() . "\n");
	}
	$userData = $userData->fetchArray(SQLITE3_ASSOC);
	if (!$userData) { // no user
		exit("[ERROR] No user matching that username.\n");
	}
}

// We should have $userData now.

print_r($userData);

// Do we already have a access/client token for the user?

if (strlen($userData["access_token"]) == 0 || strlen($userData["client_token"]) == 0) {

	echo "[INFO] No accessToken or clientToken on file, fetching it from Mojang...\n";

	$doAuth = authAccount($userData["account_email"], $userData["account_password"]);

	if (isset($doAuth["error"], $doAuth["errorMessage"])) {
	        echo "[ERROR] Mojang returned the following error upon attempting to authenticate:\n";
	        echo "        'error'           => " . $doAuth["error"] . "\n";
	        echo "        'errorMessage     => " . $doAuth["errorMessage"] . "\n";
	        exit("Maybe the credentials are wrong, or we've been ratelimited...\n");
	} elseif (isset($doAuth["accessToken"], $doAuth["clientToken"], $doAuth["selectedProfile"])) {

	        echo "[INFO] Confirmed login.\n";
        	echo "       Username: " . $doAuth["selectedProfile"]["name"] . "\n";
	        echo "           UUID: " . $doAuth["selectedProfile"]["id"]   . "\n";
	//        $user_info["user"]              = $doAuth["selectedProfile"]["name"];
	//        $user_info["uuid"]              = $doAuth["selectedProfile"]["id"];
	//        $user_info["access_token"]      = $doAuth["accessToken"];
	//        $user_info["client_token"]      = $doAuth["clientToken"];
	}

} else {

	// Cool, we already have one, so let's check if it's valid to use.
	if (validateToken($userData["access_token"])) {
		exit("[INFO] " . $userData["account_username"] . "'s token is valid, exiting.\n");
	} else {

	// Attempt to refresh it, and if that fails, grab a new one with the username and password.

	// Part 1: Attempt refresh

	$tryRefresh = refreshAccount($userData["access_token"], null); // we don't need to provide a client token, especially if it's gotten goofed up by logging in separately

	 if (isset($tryRefresh["error"], $tryRefresh["errorMessage"])) {
                echo "[INFO] Mojang returned the following error upon attempting to refresh the token:\n";
                echo "        'error'           => " . $tryRefresh["error"] . "\n";
                echo "        'errorMessage     => " . $tryRefresh["errorMessage"] . "\n";
                echo "[INFO] Now trying with username and password...\n";

		// TODO: Add try with username and password

        }
	var_dump($tryRefresh);

	}

	exit("[INFO] TODO: Refresh or validate the token.\n");

}
//

// At this point we should have an array called $doAuth containing the following:
// ["accessToken"]
// ["clientToken"]
// ["

echo "[INFO] Updating user's client token...\n";

$whereClause = (($inputType == "email") ? "account_email" : "account_username") . " = '" . $db->escapeString($user_info["email_or_username"]) . "'";

// also takes care of things if (for some reason) the account has been updated)
$updateUser = $db->prepare("UPDATE accounts SET access_token = :access, client_token = :client, account_username = :user WHERE " . $whereClause);
$updateUser->bindValue(':access', $doAuth["accessToken"], SQLITE3_TEXT);
$updateUser->bindValue(':client', $doAuth["clientToken"], SQLITE3_TEXT);
$updateUser->bindValue(':user',   $doAuth["selectedProfile"]["name"], SQLITE3_TEXT);
$result = $updateUser->execute();

echo "[INFO] Updated account with accessToken, clientToken, and username.\n";

