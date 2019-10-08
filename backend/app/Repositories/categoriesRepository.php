<?php

namespace App\Repositories;

use App\Models\categories;
use App\Repositories\BaseRepository;

/**
 * Class categoriesRepository
 * @package App\Repositories
 * @version October 8, 2019, 1:19 am UTC
*/

class categoriesRepository extends BaseRepository
{
    /**
     * @var array
     */
    protected $fieldSearchable = [
        'name',
        'description',
        'images',
        'products_amount',
        'parent_category_id',
        'level'
    ];

    /**
     * Return searchable fields
     *
     * @return array
     */
    public function getFieldsSearchable()
    {
        return $this->fieldSearchable;
    }

    /**
     * Configure the Model
     **/
    public function model()
    {
        return categories::class;
    }
}
