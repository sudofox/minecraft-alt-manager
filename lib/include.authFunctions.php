<?php


function authAccount($username, $password) {

	$payload = [
		    "agent" => [
			"name" => "Minecraft",
			"version" => 1
		    ],
		    "username" => $username,
		    "password" => $password
		];

	$auth = curl_init();

	curl_setopt($auth, CURLOPT_URL, "https://authserver.mojang.com/authenticate");
	curl_setopt($auth, CURLOPT_POST, 1);
	curl_setopt($auth, CURLOPT_POSTFIELDS, json_encode($payload,true));
	curl_setopt($auth, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($auth, CURLOPT_HTTPHEADER, ["Content-Type: application/json"]);
	$doAuth = curl_exec($auth);
	curl_close($auth);

	return json_decode($doAuth, true);
}

function refreshAccount($accessToken, $clientToken) {
	$payload = [
		"accessToken" => $accessToken,
		"clientToken" => $clientToken
	];

	$auth = curl_init();

	curl_setopt($auth, CURLOPT_URL, "https://authserver.mojang.com/refresh");
	curl_setopt($auth, CURLOPT_POST, 1);
	curl_setopt($auth, CURLOPT_POSTFIELDS, json_encode($payload,true));
	curl_setopt($auth, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($auth, CURLOPT_HTTPHEADER, ["Content-Type: application/json"]);
	$doAuth = curl_exec($auth);
	curl_close($auth);

	return json_decode($doAuth, true);
}

/*
	// will add this soon
function validateToken($accessToken) {

	// We don't _actually_ need the 
*/

//var_dump(authAccount("email@example.com", "password"));
//var_dump(refreshAccount("auth-token-here","client-token-here"));
