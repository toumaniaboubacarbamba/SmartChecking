<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\VisitorController;
use App\Http\Controllers\UserController;
use Illuminate\Support\Facades\Route;

// ── Routes publiques ──────────────────────────────────────────────────────────
Route::post('/login', [AuthController::class, 'login']);

// ── Routes protégées (token requis) ───────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);

    // Visitors CRUD (Vigile + Admin)
    Route::get('/visitors',             [VisitorController::class, 'index']);
    Route::post('/visitors',            [VisitorController::class, 'store']);
    Route::delete('/visitors/{id}',     [VisitorController::class, 'destroy']);

    // Export (Vigile + Admin)
    Route::post('/visitors/export/csv', [VisitorController::class, 'exportCsv']);
    Route::post('/visitors/export/pdf', [VisitorController::class, 'exportPdf']);

    // Gestion des comptes (Admin seulement)
    Route::middleware('check.admin')->group(function () {
        Route::get('/users',          [UserController::class, 'index']);
        Route::post('/users',         [UserController::class, 'store']);
        Route::delete('/users/{id}',  [UserController::class, 'destroy']);
    });
});
