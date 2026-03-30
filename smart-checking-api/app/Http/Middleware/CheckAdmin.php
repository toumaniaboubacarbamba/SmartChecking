<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckAdmin
{
    /**
     * Handle an incoming request.
     *
     * @param  Closure(Request): (Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {// Vérifie que l'utilisateur connecté est bien Admin
        if ($request->user()->role !== 'Admin') {
            return response()->json([
                'message' => 'Accès refusé. Réservé aux administrateurs.',
            ], 403);
        }

        return $next($request);
    }
}
