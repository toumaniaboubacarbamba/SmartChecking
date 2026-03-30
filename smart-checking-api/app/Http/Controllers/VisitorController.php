<?php

namespace App\Http\Controllers;

use App\Models\Visitor;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Symfony\Component\HttpFoundation\JsonResponse;

class VisitorController extends Controller
{
   //--Get all visitors
    public function index(): JsonResponse
    {
        //
        $visitors = Visitor::latest()->get();
        return response()->json($visitors, 200);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function store(Request $request): JsonResponse
    {
        //
        $data = $request->validate([
            'last_name' => 'required|string',
            'first_name' => 'required|string',
            'email'=> 'nullable|email',
            'gender' => ['required', 'string', Rule::in(['Masculin', 'Féminin', 'masculin', 'féminin', 'Male', 'Female'])],
            'visit_reason' => 'required|string',
            'card_type' => 'required|string',
            'visitor_type' => 'required|string',
            'photo_path' => 'nullable|string',
            'entry_method' => 'required|string',
            'entry_time' => 'required|date',
            'exit_time' => 'nullable|date',
            'visitor_count' => 'integer|min:1',
            'company' => 'nullable|string',
        ]);

        //associer le visiteur à l'utilisateur connecté
        $data['user_id'] = $request->user()->id;

        $visitor = Visitor::create($data);
        return response()->json($visitor, 201);
    }


    public function destroy(string $id): JsonResponse
    {
        //
        $visitor = Visitor::findOrFail($id);
        $visitor->delete();

        return response()->json([
            'message' => 'Visiteur supprimé avec succès'
        ], 200);
    }

    // ── EXPORT CSV ────────────────────────────────────────────────────────────

    public function exportCsv(Request $request)
    {
        $request->validate([
            'ids' => 'required|array',
            'ids.*' => 'integer',
        ]);

        $visitors = Visitor::whereIn('id', $request->ids)->get();

        // En-têtes CSV
        $headers = [
            'Content-Type'        => 'text/csv; charset=UTF-8',
            'Content-Disposition' => 'attachment; filename="visiteurs_' . now()->format('Ymd_His') . '.csv"',
        ];

        // Construction du CSV
        $callback = function () use ($visitors) {
            $handle = fopen('php://output', 'w');

            // BOM UTF-8 pour Excel
            fprintf($handle, chr(0xEF) . chr(0xBB) . chr(0xBF));

            // Ligne d'en-tête
            fputcsv($handle, [
                'ID',
                'Nom',
                'Prénoms',
                'Email',
                'Téléphone',
                'Sexe',
                'Motif',
                'Type de carte',
                'Type de visiteur',
                'Méthode d\'entrée',
                'Heure d\'entrée',
                'Heure de sortie',
                'Nombre de visiteurs',
                'Entreprise',
            ], ';');

            // Lignes de données
            foreach ($visitors as $v) {
                fputcsv($handle, [
                    $v->id,
                    $v->last_name,
                    $v->first_name,
                    $v->email ?? '',
                    $v->phone ?? '',
                    $v->gender,
                    $v->visit_reason,
                    $v->card_type,
                    $v->visitor_type,
                    $v->entry_method,
                    $v->entry_time->format('d/m/Y H:i'),
                    $v->exit_time?->format('d/m/Y H:i') ?? '',
                    $v->visitor_count,
                    $v->company ?? '',
                ], ';');
            }

            fclose($handle);
        };

        return response()->stream($callback, 200, $headers);
    }

    // ── EXPORT PDF ────────────────────────────────────────────────────────────

    public function exportPdf(Request $request)
    {
        $request->validate([
            'ids'   => 'required|array',
            'ids.*' => 'integer',
        ]);

        $visitors = Visitor::whereIn('id', $request->ids)->get();

        $pdf = Pdf::loadView('exports.visitors_pdf', [
            'visitors'    => $visitors,
            'generated_at' => now()->format('d/m/Y à H:i'),
        ])->setPaper('a4', 'landscape');

        return $pdf->download('visiteurs_' . now()->format('Ymd_His') . '.pdf');
    }
}
