import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_checking/entities/visitor.dart';
import 'package:smart_checking/view_models/auth_view_model.dart';
import 'package:smart_checking/view_models/visitor_view_model.dart';
import 'package:smart_checking/ui/pages/login_page.dart';
import 'package:smart_checking/ui/pages/visitor_detail_page.dart';
import 'package:smart_checking/ui/pages/add_visitor_page.dart';

const kGreen = Color(0xFF0CC17C);
const kRed   = Color(0xFFF52626);
const kBlue  = Color(0xFF03A9F4);
const kGrey  = Color(0xFF4B4B4B);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCtrl   = TextEditingController();
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisitorViewModel>().fetchVisitors();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _toggleSelect(String id) {
    setState(() {
      _selectedIds.contains(id)
          ? _selectedIds.remove(id)
          : _selectedIds.add(id);
    });
  }

  void _selectAll(List<Visitor> visitors) {
    setState(() {
      if (_selectedIds.length == visitors.length) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(visitors.map((v) => v.id));
      }
    });
  }

  void _enterSelectionMode() {
    setState(() {
      _selectionMode = true;
      _selectedIds.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  // ── Dialogues ─────────────────────────────────────────────────────────────

  Future<void> _showDeleteDialog(VisitorViewModel vm, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Suppression enregistrement',
          textAlign: TextAlign.center,
          style: TextStyle(color: kRed, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: const Text(
          'Êtes vous sûr de vouloir supprimer cet utilisateur ? '
              'Vous ne pourrez plus revenir en arrière.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Retour', style: TextStyle(color: kRed, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer', style: TextStyle(color: kGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok == true) await vm.deleteVisitor(id);
  }

  Future<void> _showExportDialog(String format) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Exportation en .$format',
          textAlign: TextAlign.center,
          style: const TextStyle(color: kGreen, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          'Vous êtes sur le point d\'exporter les visiteurs sélectionnés en .$format.\n'
              'Êtes-vous sûr de vouloir continuer ?',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Retour', style: TextStyle(color: kRed, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer', style: TextStyle(color: kGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      // TODO: export réel ici
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded, color: kGreen, size: 64),
              const SizedBox(height: 16),
              Text(
                'Votre fichier .$format a bien été exporté.\n'
                    'Consultez votre dossier de téléchargement.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ],
          ),
        ),
      );
      _exitSelectionMode();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vm       = context.watch<VisitorViewModel>();
    final visitors = vm.visitors;

    return Scaffold(
      backgroundColor: Colors.white,

      // ── AppBar ─────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: kGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _selectionMode ? '${_selectedIds.length}' : 'SmartChecking',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          if (_selectionMode) ...[
            // Icône poubelle
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: _selectedIds.isEmpty
                  ? null
                  : () {
                for (final id in _selectedIds.toList()) {
                  _showDeleteDialog(vm, id);
                }
              },
            ),
            // Menu export en mode sélection
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'all') _selectAll(visitors);
                if (value == 'csv') _showExportDialog('csv');
                if (value == 'pdf') _showExportDialog('pdf');
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'all', child: Text('Tout sélectionner')),
                PopupMenuItem(value: 'csv', child: Text('Exporter en .csv')),
                PopupMenuItem(value: 'pdf', child: Text('Exporter en .pdf')),
              ],
            ),
            TextButton(
              onPressed: _exitSelectionMode,
              child: const Text('Annulez', style: TextStyle(color: Colors.white)),
            ),
          ] else
          // Menu normal
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'select') _enterSelectionMode();
                if (value == 'logout') _logout();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'select', child: Text('Sélectionner')),
                PopupMenuItem(value: 'logout', child: Text('Se déconnecter')),
              ],
            ),
        ],
      ),

      // ── Body ───────────────────────────────────────────────────────────
      body: Column(
        children: [
          // Barre de recherche ou sélection tout
          if (_selectionMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Checkbox(
                    value: _selectedIds.length == visitors.length &&
                        visitors.isNotEmpty,
                    onChanged: (_) => _selectAll(visitors),
                    activeColor: kGreen,
                  ),
                  const Text('Sélectionner tout'),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: TextField(
                controller: _searchCtrl,
                onChanged: vm.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Rechercher un nom, numéro d\'ID, etc...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  suffixIcon: const Icon(Icons.filter_list, color: kGreen),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

          // Liste des visiteurs
          Expanded(
            child: _buildList(vm, visitors),
          ),
        ],
      ),

      // ── Bottom Nav ─────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        height: 62,
        color: kGreen,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navBtn(Icons.home_rounded, active: true, onTap: () {}),
            _navBtn(
              Icons.contacts_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddVisitorPage(entryMethod: 'Entrée manuelle'),
                ),
              ),
            ),
            _navBtn(
              Icons.camera_alt_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddVisitorPage(entryMethod: 'Scan ID'),
                ),
              ),
            ),
            _navBtn(Icons.face_rounded, onTap: () {}),
          ],
        ),
      ),
    );
  }

  // ── Widget bouton nav ──────────────────────────────────────────────────────

  Widget _navBtn(IconData icon,
      {bool active = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: active
            ? BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(12))
            : null,
        child: Icon(icon,
            color: active ? Colors.white : Colors.white60, size: 26),
      ),
    );
  }

  // ── Liste ──────────────────────────────────────────────────────────────────

  Widget _buildList(VisitorViewModel vm, List<Visitor> visitors) {
    // Chargement
    if (vm.isLoading && visitors.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: kGreen));
    }

    // Erreur
    if (vm.error != null && visitors.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 10),
          Text(vm.error!.message,
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: vm.fetchVisitors,
            style: ElevatedButton.styleFrom(backgroundColor: kGreen),
            child: const Text('Réessayer',
                style: TextStyle(color: Colors.white)),
          ),
        ]),
      );
    }

    // Vide
    if (visitors.isEmpty) {
      return const Center(
        child: Text('Aucun visiteur',
            style: TextStyle(color: Colors.grey, fontSize: 15)),
      );
    }

    // Liste
    return RefreshIndicator(
      color: kGreen,
      onRefresh: vm.fetchVisitors,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        itemCount: visitors.length,
        itemBuilder: (context, i) {
          final v = visitors[i];
          return _buildCard(v, vm);
        },
      ),
    );
  }

  // ── Card visiteur ──────────────────────────────────────────────────────────

  Widget _buildCard(Visitor v, VisitorViewModel vm) {
    final isSelected = _selectedIds.contains(v.id);

    // Couleur du badge selon le type
    Color badgeColor = kGreen;
    if (v.visitorType.toLowerCase() == 'employé') badgeColor = kBlue;
    if (v.visitorType.toLowerCase() == 'invité') badgeColor = Colors.orange;

    String formatTime(DateTime dt) =>
        '${dt.hour.toString().padLeft(2, '0')} : ${dt.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () {
        if (_selectionMode) {
          _toggleSelect(v.id);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VisitorDetailPage(visitor: v)),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5),
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isSelected ? const Color(0xFFE6F9F2) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 6, 10),
          child: Column(
            children: [
              // Ligne du haut : avatar + infos + menu
              Row(
                children: [
                  if (_selectionMode)
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleSelect(v.id),
                      activeColor: kGreen,
                    ),

                  // Avatar
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFE0E0E0),
                    backgroundImage: v.photoPath != null
                        ? NetworkImage(v.photoPath!)
                        : null,
                    child: v.photoPath == null
                        ? const Icon(Icons.person, color: Colors.grey, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Infos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${v.lastName} ${v.firstName}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(v.visitorType,
                            style: TextStyle(
                                color: badgeColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        Text(v.entryMethod,
                            style: const TextStyle(
                                color: kGrey, fontSize: 12)),
                        Text('Motif : ${v.visitReason}',
                            style: const TextStyle(
                                color: kGrey, fontSize: 12)),
                      ],
                    ),
                  ),

                  // Menu ⋮
                  if (!_selectionMode)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert,
                          color: Colors.grey, size: 20),
                      onSelected: (_) => _showDeleteDialog(vm, v.id),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Supprimer',
                              style: TextStyle(color: kRed)),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 8),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 8),

              // Ligne du bas : badge carte + heures
              Row(
                children: [
                  // Badge type de carte
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: kGreen),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(v.cardType,
                        style: const TextStyle(
                            fontSize: 11,
                            color: kGreen,
                            fontWeight: FontWeight.w500)),
                  ),

                  const Spacer(),

                  // Entrée
                  Row(children: [
                    const Icon(Icons.login_rounded, color: kGreen, size: 15),
                    const SizedBox(width: 3),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatTime(v.entryTime),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: kGreen)),
                        const Text('Entrée',
                            style: TextStyle(fontSize: 10, color: kGrey)),
                      ],
                    ),
                  ]),

                  const SizedBox(width: 16),

                  // Sortie
                  Row(children: [
                    const Icon(Icons.logout_rounded, color: kRed, size: 15),
                    const SizedBox(width: 3),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.exitTime != null
                              ? formatTime(v.exitTime!)
                              : '--:--',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: kRed),
                        ),
                        const Text('Sortie',
                            style: TextStyle(fontSize: 10, color: kGrey)),
                      ],
                    ),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}