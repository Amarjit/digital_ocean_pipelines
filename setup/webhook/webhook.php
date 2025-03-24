<?php

// Set your GitHub secret (same as in webhook settings)
// todo: should be replaced with a secret from environment variable.
$secret = $env['GITHUB_SECRET'] ?? '';  // Default to empty string if not set
$log_file = "../logs/webhook.log";  // Log file location

// Get raw request body & headers.
$payload = file_get_contents("php://input");
$signature = $_SERVER['HTTP_X_HUB_SIGNATURE_256'] ?? '';

// Verify signature.
$expected_signature = 'sha256=' . hash_hmac('sha256', $payload, $secret);

if (!hash_equals($expected_signature, $signature)) {
    file_put_contents($log_file, "[" . date("Y-m-d H:i:s") . "] Invalid signature: $signature\n", FILE_APPEND);
    http_response_code(403);
    exit("Invalid signature");
}

// Decode the JSON payload
$data = json_decode($payload, true);

// Check for push event and extract details
if (isset($data["ref"]) && isset($data["repository"]["name"])) {
    $branch = str_replace("refs/heads/", "", $data["ref"]);
    $repo_name = $data["repository"]["name"];

    // Log the valid request
    file_put_contents($log_file, "[" . date("Y-m-d H:i:s") . "] Push event: Repo=$repo_name, Branch=$branch\n", FILE_APPEND);
}

http_response_code(200);
echo "OK";
