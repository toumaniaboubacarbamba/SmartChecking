<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: Arial, sans-serif;
      font-size: 11px;
      color: #222;
      padding: 20px;
    }

    /* ── En-tête ── */
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
      padding-bottom: 12px;
      border-bottom: 2px solid #0CC17C;
    }

    .header h1 {
      font-size: 20px;
      color: #0CC17C;
      font-weight: bold;
    }

    .header p {
      font-size: 10px;
      color: #4B4B4B;
    }

    /* ── Tableau ── */
    table {
      width: 100%;
      border-collapse: collapse;
    }

    thead tr {
      background-color: #0CC17C;
      color: white;
    }

    thead th {
      padding: 8px 6px;
      text-align: left;
      font-size: 10px;
      font-weight: bold;
    }

    tbody tr:nth-child(even) {
      background-color: #F0FDF8;
    }

    tbody tr:hover {
      background-color: #E6F9F2;
    }

    tbody td {
      padding: 7px 6px;
      border-bottom: 1px solid #E0E0E0;
      font-size: 10px;
      color: #333;
    }

    /* ── Badge type visiteur ── */
    .badge {
      display: inline-block;
      padding: 2px 7px;
      border-radius: 10px;
      font-size: 9px;
      font-weight: bold;
    }
    .badge-visiteur { background: #E6F9F2; color: #0CC17C; }
    .badge-employe  { background: #E3F2FD; color: #03A9F4; }
    .badge-invite   { background: #FFF3E0; color: #FF9800; }

    /* ── Pied de page ── */
    .footer {
      margin-top: 16px;
      font-size: 9px;
      color: #4B4B4B;
      text-align: right;
    }

    .total {
      margin-top: 10px;
      font-size: 11px;
      font-weight: bold;
      color: #0CC17C;
    }
  </style>
</head>
<body>

  {{-- En-tête --}}
  <div class="header">
    <div>
      <h1>SmartChecking</h1>
      <p>Rapport des visiteurs</p>
    </div>
    <div style="text-align: right;">
      <p>Généré le {{ $generated_at }}</p>
      <p>Groupe CERCO Côte d'Ivoire</p>
    </div>
  </div>

  {{-- Tableau --}}
  <table>
    <thead>
      <tr>
        <th>#</th>
        <th>Nom & Prénoms</th>
        <th>Type</th>
        <th>Sexe</th>
        <th>Motif</th>
        <th>Carte</th>
        <th>Méthode</th>
        <th>Entrée</th>
        <th>Sortie</th>
        <th>Visiteurs</th>
        <th>Entreprise</th>
      </tr>
    </thead>
    <tbody>
      @foreach ($visitors as $v)
        <tr>
          <td>{{ $v->id }}</td>
          <td><strong>{{ $v->last_name }}</strong> {{ $v->first_name }}</td>
          <td>
            @php
              $badgeClass = match(strtolower($v->visitor_type)) {
                'employé' => 'badge-employe',
                'invité'  => 'badge-invite',
                default   => 'badge-visiteur',
              };
            @endphp
            <span class="badge {{ $badgeClass }}">{{ $v->visitor_type }}</span>
          </td>
          <td>{{ $v->gender }}</td>
          <td>{{ $v->visit_reason }}</td>
          <td>{{ $v->card_type }}</td>
          <td>{{ $v->entry_method }}</td>
          <td>{{ $v->entry_time->format('d/m/Y H:i') }}</td>
          <td>{{ $v->exit_time ? $v->exit_time->format('d/m/Y H:i') : '—' }}</td>
          <td style="text-align:center;">{{ $v->visitor_count }}</td>
          <td>{{ $v->company ?? '—' }}</td>
        </tr>
      @endforeach
    </tbody>
  </table>

  {{-- Total --}}
  <p class="total">Total : {{ $visitors->count() }} visiteur(s)</p>

  {{-- Pied de page --}}
  <p class="footer">
    SmartChecking — Groupe CERCO CI — Propriété Privée, Tous Droits Réservés
  </p>

</body>
</html>
