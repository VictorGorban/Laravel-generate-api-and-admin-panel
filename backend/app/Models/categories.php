<?php

namespace App\Models;

use Eloquent as Model;
use Illuminate\Database\Eloquent\SoftDeletes;

/**
 * Class categories
 * @package App\Models
 * @version October 8, 2019, 1:19 am UTC
 *
 * @property \Illuminate\Database\Eloquent\Collection products
 * @property string name
 * @property string description
 * @property string images
 * @property integer products_amount
 * @property integer parent_category_id
 * @property integer level
 */
class categories extends Model
{
    use SoftDeletes;

    public $table = 'categories';
    
    const CREATED_AT = 'created_at';
    const UPDATED_AT = 'updated_at';


    protected $dates = ['deleted_at'];


    public $fillable = [
        'name',
        'description',
        'images',
        'products_amount',
        'parent_category_id',
        'level'
    ];

    /**
     * The attributes that should be casted to native types.
     *
     * @var array
     */
    protected $casts = [
        'id' => 'integer',
        'name' => 'string',
        'description' => 'string',
        'images' => 'string',
        'products_amount' => 'integer',
        'parent_category_id' => 'integer',
        'level' => 'integer'
    ];

    /**
     * Validation rules
     *
     * @var array
     */
    public static $rules = [
        'name' => 'required'
    ];

    /**
     * @return \Illuminate\Database\Eloquent\Relations\HasMany
     **/
    public function products()
    {
        return $this->hasMany(\App\Models\Product::class, 'category_id');
    }
}
