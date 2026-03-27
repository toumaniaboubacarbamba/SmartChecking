<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('visitors', function (Blueprint $table) {
            $table->id();
            $table->string('first_name');
            $table->string('last_name');
            $table->string('email')->nullable();
            $table->string('phone')->nullable();
            $table->enum('gender',['Masculin', 'Féminin']);
            $table->string('visit_reason');
            $table->string('card_type');
            $table->string('visitor_type');
            $table->string('photo_path')->nullable();
            $table->string('entry_method');
            $table->dateTime('entry_time');
            $table->dateTime('exit_time')->nullable();
            $table->integer('visitor_count')->default(1);
            $table->string('company')->nullable();


            $table->foreignId('user_id')->constrained()->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('visitors');
    }
};
