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

function refreshAccount($accessToken, $clientToken = null) {


	$payload["accessToken"] = $accessToken;
	if (!is_null($clientToken)) {
		$payload["clientToken"] = $clientToken;
	}

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


function validateToken($accessToken) {

	$payload = [ "accessToken" => $accessToken ];
        $checkValid = curl_init();

        curl_setopt($checkValid, CURLOPT_URL, "https://authserver.mojang.com/validate");
        curl_setopt($checkValid, CURLOPT_POST, 1);
        curl_setopt($checkValid, CURLOPT_POSTFIELDS, json_encode($payload,true));
        curl_setopt($checkValid, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($checkValid, CURLOPT_HTTPHEADER, ["Content-Type: application/json"]);
        curl_exec($checkValid);

	$result = curl_getinfo($checkValid);
        curl_close($checkValid);
	return ($result["http_code"] == 204);

}


//var_dump(authAccount("email@example.com", "password"));
//var_dump(refreshAccount("auth-token-here","client-token-here"));
