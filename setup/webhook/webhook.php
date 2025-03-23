<?php

// Function to load environment variables from a .env file
function loadEnv($filePath) {
    $env = [];
    if (file_exists($filePath)) {
        $lines = file($filePath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            // Ignore comments
            if (strpos($line, '#') === 0) continue;
            list($key, $value) = explode('=', $line, 2);
            $env[trim($key)] = trim($value);
        }
    }
    return $env;
}

// Load environment variables from .env
$env = loadEnv(__DIR__ . '/.env');

// Set your GitHub secret (same as in webhook settings)
$secret = $env['GITHUB_SECRET'] ?? '';  // Default to empty string if not set
$log_file = "/var/www/$DOMAIN/logs/webhook.log";  // Log file location

// Check if the 'what' query parameter is set to 'yes'
if (!isset($_GET['what']) || $_GET['what'] !== 'yes') {
    file_put_contents($log_file, "[" . date("Y-m-d H:i:s") . "] Invalid request: missing or incorrect 'what' param\n", FILE_APPEND);
    http_response_code(400); // Bad Request
    exit("Invalid request");
}

// Get raw request body & headers
$payload = file_get_contents("php://input");
$signature = $_SERVER['HTTP_X_HUB_SIGNATURE_256'] ?? '';

// Verify signature
$expected_signature = 'sha256=' . hash_hmac('sha256', $payload, $secret);
if (!hash_equals($expected_signature, $signature)) {
    file_put_contents($log_file, "[" . date("Y-m-d H:i:s") . "] Invalid signature: $signature\n", FILE_APPEND);
    http_response_code(403); // Forbidden
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
