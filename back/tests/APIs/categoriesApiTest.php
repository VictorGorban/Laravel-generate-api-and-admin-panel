<?php namespace Tests\APIs;

use Illuminate\Foundation\Testing\WithoutMiddleware;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;
use Tests\ApiTestTrait;
use App\Models\categories;

class categoriesApiTest extends TestCase
{
    use ApiTestTrait, WithoutMiddleware, DatabaseTransactions;

    /**
     * @test
     */
    public function test_create_categories()
    {
        $categories = factory(categories::class)->make()->toArray();

        $this->response = $this->json(
            'POST',
            '/api/categories', $categories
        );

        $this->assertApiResponse($categories);
    }

    /**
     * @test
     */
    public function test_read_categories()
    {
        $categories = factory(categories::class)->create();

        $this->response = $this->json(
            'GET',
            '/api/categories/'.$categories->id
        );

        $this->assertApiResponse($categories->toArray());
    }

    /**
     * @test
     */
    public function test_update_categories()
    {
        $categories = factory(categories::class)->create();
        $editedcategories = factory(categories::class)->make()->toArray();

        $this->response = $this->json(
            'PUT',
            '/api/categories/'.$categories->id,
            $editedcategories
        );

        $this->assertApiResponse($editedcategories);
    }

    /**
     * @test
     */
    public function test_delete_categories()
    {
        $categories = factory(categories::class)->create();

        $this->response = $this->json(
            'DELETE',
             '/api/categories/'.$categories->id
         );

        $this->assertApiSuccess();
        $this->response = $this->json(
            'GET',
            '/api/categories/'.$categories->id
        );

        $this->response->assertStatus(404);
    }
}
