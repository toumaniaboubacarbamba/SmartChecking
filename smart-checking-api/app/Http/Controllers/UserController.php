<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;


class UserController extends Controller
{
    // ── Créer un vigile (Admin seulement) ─────────────────────────────────────

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
            'role'     => 'in:Vigile,Admin', // optionnel, Vigile par défaut
        ]);

        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
            'role'     => $request->role ?? 'Vigile',
        ]);

        return response()->json([
            'message' => 'Compte créé avec succès',
            'user'    => [
                'id'    => $user->id,
                'name'  => $user->name,
                'email' => $user->email,
                'role'  => $user->role,
            ],
        ], 201);
    }

    // ── Liste des vigiles (Admin seulement) ───────────────────────────────────

    public function index(): JsonResponse
    {
        $users = User::select('id', 'name', 'email', 'role', 'created_at')
                     ->orderBy('created_at', 'desc')
                     ->get();

        return response()->json($users, 200);
    }

    // ── Supprimer un vigile (Admin seulement) ─────────────────────────────────

    public function destroy(int $id): JsonResponse
    {
        $user = User::findOrFail($id);

        // On ne peut pas supprimer son propre compte
        if ($user->id === request()->user()->id) {
            return response()->json([
                'message' => 'Vous ne pouvez pas supprimer votre propre compte.',
            ], 403);
        }

        $user->delete();

        return response()->json([
            'message' => 'Compte supprimé avec succès',
        ], 200);
    }
}
