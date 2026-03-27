import 'package:flutter/material.dart';
class PersonCard extends StatelessWidget {
  final String name;
  final String role;
  final String entryType;
  final String reason;
  final String idType;
  final String entryTime;
  final String exitTime;
  final String imageUrl;
  final bool isEmployee;
  final bool showActionButtons;

  const PersonCard({
    super.key,
    required this.name,
    required this.role,
    required this.entryType,
    required this.reason,
    required this.idType,
    required this.entryTime,
    required this.exitTime,
    required this.imageUrl,
    this.isEmployee = false,
    this.showActionButtons = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // En-tête avec photo + infos
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(imageUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        role,
                        style: TextStyle(
                          color: isEmployee
                              ? const Color(0xFF03A9F4)
                              : const Color(0xFF0CC17C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$entryType • Motif : $reason',
                        style: const TextStyle(
                          color: Color(0xFF4B4B4B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: Color(0xFF4B4B4B)),
              ],
            ),

            const SizedBox(height: 12),

            // Ligne ID Type + Heures
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    idType,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                const Spacer(),

                // Bouton Entrée
                _buildTimeButton(
                  icon: Icons.login,
                  time: entryTime,
                  color: const Color(0xFF0CC17C),
                  label: 'Entrée',
                ),

                const SizedBox(width: 12),

                // Bouton Sortie
                _buildTimeButton(
                  icon: Icons.logout,
                  time: exitTime,
                  color: const Color(0xFFF52626),
                  label: 'Sortie',
                ),
              ],
            ),

            // Boutons d'actions (uniquement pour Lucy Kun)
            if (showActionButtons)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(Icons.home, 'Entrée'),
                    const SizedBox(width: 8),
                    _buildActionButton(Icons.people, ''),
                    const SizedBox(width: 8),
                    _buildActionButton(Icons.camera_alt, ''),
                    const SizedBox(width: 8),
                    _buildActionButton(Icons.emoji_emotions, 'Sortie', isGreen: true),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton({
    required IconData icon,
    required String time,
    required Color color,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 4),
              Text(
                time,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, {bool isGreen = false}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isGreen ? const Color(0xFF0CC17C) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isGreen ? Colors.white : Colors.grey[700],
        size: 22,
      ),
    );
  }
}