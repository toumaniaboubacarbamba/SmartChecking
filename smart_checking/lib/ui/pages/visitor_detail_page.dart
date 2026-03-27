import 'package:flutter/material.dart';
import 'package:smart_checking/entities/visitor.dart';

const kGreen = Color(0xFF0CC17C);
const kGrey  = Color(0xFF4B4B4B);
const kBlue  = Color(0xFF03A9F4);

class VisitorDetailPage extends StatelessWidget {
  final Visitor visitor;

  const VisitorDetailPage({super.key, required this.visitor});

  // Couleur du badge selon le type de visiteur
  Color _badgeColor() {
    switch (visitor.visitorType.toLowerCase()) {
      case 'employé':  return kBlue;
      case 'invité':   return Colors.orange;
      default:         return kGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreen,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: kGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: Column(
        children: [
          // ── Photo (sur fond vert) ──────────────────────────────────────
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white24,
              backgroundImage: visitor.photoPath != null
                  ? NetworkImage(visitor.photoPath!)
                  : null,
              child: visitor.photoPath == null
                  ? const Icon(Icons.person, color: Colors.white, size: 60)
                  : null,
            ),
          ),
          const SizedBox(height: 24),

          // ── Card blanche avec les infos ────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom + type
                    Text(
                      '${visitor.lastName} ${visitor.firstName}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      visitor.visitorType,
                      style: TextStyle(
                        color: _badgeColor(),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(thickness: 0.5),
                    const SizedBox(height: 16),

                    // ── Infos principales ────────────────────────────────
                    _infoRow(
                      icon: Icons.login_rounded,
                      title: visitor.visitReason,
                      subtitle: 'Motif de la venue',
                    ),
                    const SizedBox(height: 16),
                    _infoRow(
                      icon: Icons.badge_outlined,
                      title: visitor.cardType,
                      subtitle: 'Pièce d\'identité montrée',
                    ),
                    const SizedBox(height: 16),
                    _infoRow(
                      icon: Icons.people_outline,
                      title: '${visitor.visitorCount} Adulte${visitor.visitorCount > 1 ? 's' : ''}',
                      subtitle: 'Nombre de personnes entrées',
                    ),

                    // Entreprise (si présente)
                    if (visitor.company != null &&
                        visitor.company!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _infoRow(
                        icon: Icons.business_outlined,
                        title: visitor.company!,
                        subtitle: 'Nom de l\'Entreprise',
                      ),
                    ],

                    // Email (si présent)
                    if (visitor.email != null &&
                        visitor.email!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _infoRow(
                        icon: Icons.mail_outline,
                        title: visitor.email!,
                        subtitle: 'Adresse email',
                      ),
                    ],

                    // Téléphone (si présent)
                    if (visitor.phone != null &&
                        visitor.phone!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _infoRow(
                        icon: Icons.phone_outlined,
                        title: visitor.phone!,
                        subtitle: 'Numéro de téléphone',
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Heures entrée / sortie
                    _infoRow(
                      icon: Icons.access_time_rounded,
                      title: _formatTime(visitor.entryTime),
                      subtitle: 'Heure d\'entrée',
                    ),
                    if (visitor.exitTime != null) ...[
                      const SizedBox(height: 16),
                      _infoRow(
                        icon: Icons.access_time_outlined,
                        title: _formatTime(visitor.exitTime!),
                        subtitle: 'Heure de sortie',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget ligne d'info ────────────────────────────────────────────────────
  Widget _infoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: kGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: kGreen, size: 20),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: kGrey),
            ),
          ],
        ),
      ],
    );
  }

  // ── Format heure ───────────────────────────────────────────────────────────
  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}