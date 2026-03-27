<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\VisitorController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

//publique
Route::post('/login', [AuthController::class, 'login']);

//protégé
Route::middleware('auth:sanctum')->group(function (){
    //Auth
    Route::post('/logout', [AuthController::class, 'logout']);

    //Visitor Crud
    Route::get('/visitors', [VisitorController::class, 'index']);
    Route::post('/visitors', [VisitorController::class, 'store']);
    Route::delete('/visitors/{id}', [VisitorController::class, 'destroy']);

    // Export
    Route::post('/visitors/export/csv', [VisitorController::class, 'exportCsv']);
    Route::post('/visitors/export/pdf', [VisitorController::class, 'exportPdf']);
});
