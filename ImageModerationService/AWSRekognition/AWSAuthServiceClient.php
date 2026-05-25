<?php

namespace App\Services\ImageModerationService\AWSRekognition;

use DateTime;
use Google\Api\Http;

class AWSAuthServiceClient
{
    private string $accessKey;
    private string $secretKey;
    private string $region;
    private string $service;

    public function __construct(
        string $accessKey,
        string $secretKey,
        string $region,
        string $service = 'rekognition'
    ) {
        $this->accessKey = $accessKey;
        $this->secretKey = $secretKey;
        $this->region = $region;
        $this->service = $service;
    }

    /**
     * Signs a request and returns the headers to be added.
     *
     * @param string $method  HTTP method (e.g. 'POST')
     * @param string $uri     Canonical URI (e.g., '/...')
     * @param array  $query   Query parameters as key-value pairs
     * @param array  $headers Request headers as key-value pairs
     * @param string $payload Request body (JSON string)
     * @return array: Headers to add to the request (Authorization, X-Amz-Date, Host, etc.)
     */
    public function signRequest(
        string    $method,
        string    $uri,
        array     $query,
        array     $headers,
        string    $payload,
        ?DateTime $now = null,
    ): array {
        $now = $now ?? new DateTime('UTC');

        // Create date/time values
        $longDate = $now->format('Ymd\THis\Z');
        $shortDate = $now->format('Ymd');

        // Set required headers
        if (empty($headers['Host'])) {
            $headers['Host'] = "rekognition.{$this->region}.amazonaws.com";
        }
        $headers['X-Amz-Date'] = $longDate;

        // For Rekognition, the Content-AiDetectionType header is required.
        // If a payload exists, ensure its type is set and set the target
        if (!empty($payload)) {
            $headers['Content-Type'] = $headers['Content-Type'] ?? 'application/x-amz-json-1.1';
        }

        // Create a canonical request
        $canonicalRequest = $this->createCanonicalRequest($method, $uri, $query, $headers, $payload);

        // Create the string to sign
        $stringToSign = $this->createStringToSign($longDate, $shortDate, $canonicalRequest);

        // Calculate the signature
        $signature = $this->calculateSignature($shortDate,$stringToSign);

        // Build the authorization header;
        $signedHeaders = $this->getSignedHeaders($headers);
        $credentialScope = "{$shortDate}/{$this->region}/{$this->service}/aws4_request";

        $headers['Authorization'] = "AWS4-HMAC-SHA256 Credential={$this->accessKey}/{$credentialScope}, SignedHeaders={$signedHeaders}, Signature={$signature}";

        return $headers;
    }

    /**
     * @param string $method
     * @param string $uri
     * @param array $query
     * @param array $headers
     * @param string $payload
     * @return string
     * See: https://docs.aws.amazon.com/general/latest/gr/sigv4-create-canonical-request.html
     */
    private function createCanonicalRequest(
        string $method,
        string $uri,
        array  $query,
        array  $headers,
        string $payload
    ): string {
        // HTTP Method
        $canonical = $method . "\n";
        // Canonical URI. If the URI is empty, use '/'. Ensure it's URL-encoded.
        $canonical .= ($uri === '/' || $uri === '') ? "/\n" : rawurlencode($uri) . "\n";

        // Canonical query string
        $canonical .= $this->canonicalQueryString($query) . "\n";

        // Canonical headers
        $canonical .= $this->canonicalHeaders($headers);
        $canonical .= "\n";

        // Signed headers list
        $canonical .= $this->getSignedHeaders($headers) . "\n";

        // Payload hash
        $canonical .= hash('sha256', $payload);

        return $canonical;
    }

    /**
     * @param string $longDate
     * @param string $shortDate
     * @param string $canonicalRequest
     * @return string
     * Create string to sign
     * https://docs.aws.amazon.com/general/latest/gr/sigv4-create-string-to-sign.html
     */
    private function createStringToSign(
        string $longDate,
        string $shortDate,
        string $canonicalRequest
    ): string {
        $hash = hash('sha256', $canonicalRequest);
        return  "AWS4-HMAC-SHA256\n"
            . "{$longDate}\n"
            . "{$shortDate}/{$this->region}/{$this->service}/aws4_request\n"
            . "{$hash}";
    }

    private function calculateSignature(
        string $shortDate,
        string $stringToSign,
    ): string {
        $kSecret = 'AWS4' . $this->secretKey;
        $kDate = hash_hmac('sha256', $shortDate, $kSecret, true);
        $kRegion = hash_hmac('sha256', $this->region, $kDate, true);
        $kService = hash_hmac('sha256', $this->service, $kRegion, true);
        $kSigning = hash_hmac('sha256', 'aws4_request', $kService, true);

        return hash_hmac('sha256', $stringToSign, $kSigning);
    }

    private function canonicalQueryString(array $query): string {
        if (empty($query)) {
            return '';
        }
        $encoded = [];
        foreach ($query as $k => $v) {
            $encoded[rawurlencode($k)] = rawurlencode($v);
        }
        ksort($encoded);
        $pairs = [];
        foreach ($encoded as $k => $v) {
            $pairs[] = "{$k}={$v}";
        }
        return implode('&', $pairs);
    }

    private function canonicalHeaders(array $headers): string {
        $canonical = [];
        // Header names must be lowercased for sorting
        $lowercaseHeaders = [];
        foreach ($headers as $name => $value) {
            $lowercaseHeaders[strtolower($name)] = trim($value);
        }

        // Sort by header name
        ksort($lowercaseHeaders);

        foreach ($lowercaseHeaders as $name => $value) {
            // Canonical header format: "lowercase-name:trimmed-value\n"
            $canonical[] = "{$name}:{$value}";
        }
        return implode("\n", $canonical) . "\n";
    }

    private function getSignedHeaders(array $headers): string {
        $names = array_keys($headers);
        // Lowercase and sort
        $names = array_map('strtolower',$names);
        sort($names);
        return implode(';', $names);
    }
}
