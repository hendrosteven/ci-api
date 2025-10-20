<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->get('/', 'Home::index');

$routes->group('api', function ($routes) {
    //Auth
    $routes->post('login', 'Api\AuthController::login');
    $routes->post('register', 'Api\AuthController::register');

    //Products protected routes
    $routes->group('products', ['filter' => 'jwt'], function ($routes) {
        $routes->get('/', 'Api\ProductController::index');
        $routes->get('(:num)', 'Api\ProductController::show/$1');
        $routes->post('/', 'Api\ProductController::create');
        $routes->put('(:num)', 'Api\ProductController::update/$1');
        $routes->delete('(:num)', 'Api\ProductController::delete/$1');
    });
});
