<?php
namespace App\Filters;

use CodeIgniter\Filters\FilterInterface;
use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use Config\Services;
use Exception;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JWTAuthFilter implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        $header = $request->getHeaderLine('Authorization');
        if (! $header || ! preg_match('/Bearer\s(\S+)/', $header, $matches)) {
            return Services::response()
                ->setJSON(['error' => 'Missing or invalid Authorization header'])
                ->setStatusCode(ResponseInterface::HTTP_UNAUTHORIZED);
        }

        $token = $matches[1];
        $key   = getenv('JWT_SECRET') ?: 'supersecretkey';

        try {
            $decoded = JWT::decode($token, new Key($key, 'HS256'));
            // You can attach decoded user info if needed:
            $request->user = $decoded;
        } catch (Exception $e) {
            return Services::response()
                ->setJSON(['error' => 'Invalid token: ' . $e->getMessage()])
                ->setStatusCode(ResponseInterface::HTTP_UNAUTHORIZED);
        }
    }

    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null)
    {
        // Nothing after
    }
}
