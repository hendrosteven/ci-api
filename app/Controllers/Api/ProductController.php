<?php
namespace App\Controllers\Api;

use App\Models\ProductModel;
use CodeIgniter\RESTful\ResourceController;

class ProductController extends ResourceController
{
    protected $modelName = ProductModel::class;
    protected $format    = 'json';

    // Get all products
    public function index()
    {
        $products = $this->model->findAll();
        return $this->respond($products);
    }

    // Get a single product by ID
    public function show($id = null)
    {
        $product = $this->model->find($id);
        if (! $product) {
            return $this->failNotFound('Product not found');
        }
        return $this->respond($product);
    }

    // Create a new product
    public function create()
    {
        $data = $this->request->getJSON(true);
        if (! $this->model->insert($data)) {
            return $this->failValidationErrors($this->model->errors());
        }
        return $this->respondCreated(['message' => 'Product created successfully']);
    }

    // Update an existing product
    public function update($id = null)
    {
        $data = $this->request->getJSON(true);
        if (! $this->model->find($id)) {
            return $this->failNotFound('Product not found');
        }
        if (! $this->model->update($id, $data)) {
            return $this->failValidationErrors($this->model->errors());
        }
        return $this->respond(['message' => 'Product updated successfully']);
    }

    // Delete a product
    public function delete($id = null)
    {
        if (! $this->model->find($id)) {
            return $this->failNotFound('Product not found');
        }
        $this->model->delete($id);
        return $this->respondDeleted(['message' => 'Product deleted successfully']);
    }
}
