<?php
namespace App\Controllers\Api;

use App\Models\UserModel;
use CodeIgniter\RESTful\ResourceController;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class AuthController extends ResourceController
{
    private $key;

    public function __construct()
    {
        $this->key = getenv('JWT_SECRET') ?: 'supersecretkey';
    }

    public function register()
    {
        $rules = [
            'name'     => 'required|min_length[3]',
            'email'    => 'required|valid_email|is_unique[users.email]',
            'password' => 'required|min_length[6]',
        ];

        if (! $this->validate($rules)) {
            return $this->failValidationErrors($this->validator->getErrors());
        }

        $userModel = new UserModel();
        $userModel->save([
            'name'     => $this->request->getVar('name'),
            'email'    => $this->request->getVar('email'),
            'password' => password_hash($this->request->getVar('password'), PASSWORD_BCRYPT),
        ]);

        return $this->respondCreated(['message' => 'User registered successfully']);
    }

    public function login()
    {
        $userModel = new UserModel();
        $email     = $this->request->getVar('email');
        $password  = $this->request->getVar('password');

        $user = $userModel->where('email', $email)->first();

        if (! $user || ! password_verify($password, $user['password'])) {
            return $this->failUnauthorized('Invalid email or password');
        }

        $payload = [
            'iss'   => 'ci4-jwt',   // issuer
            'sub'   => $user['id'], // subject
            'name'  => $user['name'],
            'email' => $user['email'],
            'iat'   => time(),        // issued at
            'exp'   => time() + 3600, // expires in 1 hour
        ];

        $token = JWT::encode($payload, $this->key, 'HS256');

        return $this->respond(['token' => $token]);
    }
}
