<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Symfony\Component\HttpFoundation\JsonResponse;

class AuthController extends Controller
{
    //Login
    public function login(Request $request){
        $request->validate([
            'email' => 'required|email',
            'password'=> 'required|string|min:6',
        ]);

        //if user exists
        $user = User::where('email', $request->email)->first();


        if(!$user || !Hash::check($request->password, $user->password)){
            return response()->json([
                'message' => 'Email ou mot de passe incorrect'
            ], 401);
        }
        //create token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => [
                'id'=> (string) $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'token' => $token,
            ],
        ], 200);
    }

    //Logout
    public function logout(Request $request): JsonResponse{
        //del token
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Déconnexion réussie'
        ], 200);
    }
}
