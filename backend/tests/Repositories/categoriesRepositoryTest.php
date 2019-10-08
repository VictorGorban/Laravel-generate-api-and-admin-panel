<?php namespace Tests\Repositories;

use App\Models\categories;
use App\Repositories\categoriesRepository;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;
use Tests\ApiTestTrait;

class categoriesRepositoryTest extends TestCase
{
    use ApiTestTrait, DatabaseTransactions;

    /**
     * @var categoriesRepository
     */
    protected $categoriesRepo;

    public function setUp() : void
    {
        parent::setUp();
        $this->categoriesRepo = \App::make(categoriesRepository::class);
    }

    /**
     * @test create
     */
    public function test_create_categories()
    {
        $categories = factory(categories::class)->make()->toArray();

        $createdcategories = $this->categoriesRepo->create($categories);

        $createdcategories = $createdcategories->toArray();
        $this->assertArrayHasKey('id', $createdcategories);
        $this->assertNotNull($createdcategories['id'], 'Created categories must have id specified');
        $this->assertNotNull(categories::find($createdcategories['id']), 'categories with given id must be in DB');
        $this->assertModelData($categories, $createdcategories);
    }

    /**
     * @test read
     */
    public function test_read_categories()
    {
        $categories = factory(categories::class)->create();

        $dbcategories = $this->categoriesRepo->find($categories->id);

        $dbcategories = $dbcategories->toArray();
        $this->assertModelData($categories->toArray(), $dbcategories);
    }

    /**
     * @test update
     */
    public function test_update_categories()
    {
        $categories = factory(categories::class)->create();
        $fakecategories = factory(categories::class)->make()->toArray();

        $updatedcategories = $this->categoriesRepo->update($fakecategories, $categories->id);

        $this->assertModelData($fakecategories, $updatedcategories->toArray());
        $dbcategories = $this->categoriesRepo->find($categories->id);
        $this->assertModelData($fakecategories, $dbcategories->toArray());
    }

    /**
     * @test delete
     */
    public function test_delete_categories()
    {
        $categories = factory(categories::class)->create();

        $resp = $this->categoriesRepo->delete($categories->id);

        $this->assertTrue($resp);
        $this->assertNull(categories::find($categories->id), 'categories should not exist in DB');
    }
}
