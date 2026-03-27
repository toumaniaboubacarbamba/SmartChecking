<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Visitor extends Model
{
    //
    protected $fillable = [
        'first_name',
        'last_name',
        'email',
        'phone',
        'gender',
        'visit_reason',
        'card_type',
        'visitor_type',
        'photo_path',
        'entry_method',
        'entry_time',
        'exit_time',
        'visitor_count',
        'company',
        'user_id',

    ];

    protected $casts = [
        'entry_time' => 'datetime',
        'exit_time' => 'datetime',
        'visitor_count' => 'integer',
    ];

    //un visiteur appartient à un utilisateur
    public function user(){
        return $this->belongsTo(User::class);
    }
}
