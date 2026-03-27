import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_checking/view_models/visitor_view_model.dart';
import 'package:smart_checking/ui/pages/home_page.dart';

const kGreen = Color(0xFF0CC17C);
const kRed   = Color(0xFFF52626);
const kGrey  = Color(0xFF4B4B4B);

class AddVisitorPage extends StatefulWidget {
  final String entryMethod; // 'Entrée manuelle' ou 'Scan ID'

  const AddVisitorPage({super.key, required this.entryMethod});

  @override
  State<AddVisitorPage> createState() => _AddVisitorPageState();
}

class _AddVisitorPageState extends State<AddVisitorPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers pour les champs texte
  final _lastNameCtrl  = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _phoneCtrl     = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Si Scan ID → lancer le scan automatiquement après le build
    if (widget.entryMethod == 'Scan ID') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickAndScan();
      });
    }
  }

  @override
  void dispose() {
    _lastNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── OCR : choisir image et scanner ────────────────────────────────────────

  Future<void> _pickAndScan() async {
    final picker = ImagePicker();
    final photo  = await picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    final vm = context.read<VisitorViewModel>();

    // Sauvegarder la photo du visiteur
    vm.setPhotoPath(photo.path);

    // Scanner le document
    await vm.scanDocument(photo.path);

    // Pré-remplir les controllers avec les données OCR
    if (mounted) {
      _lastNameCtrl.text  = vm.lastName;
      _firstNameCtrl.text = vm.firstName;
    }
  }

  // ── Prendre photo visiteur ─────────────────────────────────────────────────

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final photo  = await picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;
    context.read<VisitorViewModel>().setPhotoPath(photo.path);
  }

  // ── Soumettre le formulaire ────────────────────────────────────────────────

  Future<void> _onConfirm() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    // Dialog de confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirmation d\'enregistrement',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: kGreen, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: const Text(
          'Êtes vous sûr de vouloir enregistrer cette personne ? '
              'Vous ne pourrez plus modifier après avoir confirmer.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Retour',
                style: TextStyle(color: kRed, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer',
                style: TextStyle(color: kGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Soumettre via le ViewModel
    final vm      = context.read<VisitorViewModel>();
    final success = await vm.submitVisitor();

    if (!mounted) return;

    if (success) {
      // Dialog succès
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_rounded, color: kGreen, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Le visiteur a bien été enregistré !',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ],
          ),
        ),
      );

      // Retour à l'accueil
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } else {
      // Afficher l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.error?.message ?? 'Une erreur est survenue'),
          backgroundColor: kRed,
        ),
      );
    }
  }

  // ── Annuler ────────────────────────────────────────────────────────────────

  void _onCancel() {
    context.read<VisitorViewModel>().resetForm();
    Navigator.of(context).pop();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VisitorViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // AppBar simple avec flèche retour
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kGreen),
          onPressed: _onCancel,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Photo visiteur ─────────────────────────────────────────
              GestureDetector(
                onTap: _takePhoto,
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: const Color(0xFFDDDDDD),
                  backgroundImage: vm.photoPath != null
                      ? AssetImage(vm.photoPath!) as ImageProvider
                      : null,
                  child: vm.photoPath == null
                      ? const Icon(Icons.person,
                      color: Colors.white, size: 52)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // ── Titre ──────────────────────────────────────────────────
              Text(
                widget.entryMethod == 'Scan ID'
                    ? 'Scan du visiteur'
                    : 'Enregistrer une visite',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kGreen,
                ),
              ),
              const SizedBox(height: 20),

              // ── Indicateur scan en cours ───────────────────────────────
              if (vm.isScanning) ...[
                const CircularProgressIndicator(color: kGreen),
                const SizedBox(height: 8),
                const Text('Scan en cours...',
                    style: TextStyle(color: kGrey, fontSize: 13)),
                const SizedBox(height: 16),
              ],

              // ── Champs du formulaire ───────────────────────────────────

              // NOM
              _field(
                controller: _lastNameCtrl,
                hint: 'NOM',
                onChanged: vm.setLastName,
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),

              // PRÉNOMS
              _field(
                controller: _firstNameCtrl,
                hint: 'Prénoms',
                onChanged: vm.setFirstName,
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),

              // EMAIL
              _field(
                controller: _emailCtrl,
                hint: 'Email',
                onChanged: vm.setEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // NUMÉRO
              _field(
                controller: _phoneCtrl,
                hint: 'Numéro',
                onChanged: vm.setPhone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              // SEXE
              _dropdown(
                hint: 'Sexe',
                value: vm.gender.isEmpty ? null : vm.gender,
                items: const ['Masculin', 'Féminin'],
                onChanged: (v) => vm.setGender(v!),
                validator: (v) => v == null ? 'Requis' : null,
              ),
              const SizedBox(height: 12),

              // MOTIF DE LA VISITE
              _dropdown(
                hint: 'Motif de la visite',
                value: vm.visitReason.isEmpty ? null : vm.visitReason,
                items: const ['Visite', 'Travail', 'Réunion', 'Livraison', 'Autre'],
                onChanged: (v) => vm.setVisitReason(v!),
                validator: (v) => v == null ? 'Requis' : null,
              ),
              const SizedBox(height: 12),

              // TYPE DE CARTE
              _dropdown(
                hint: 'Type de Carte',
                value: vm.cardType.isEmpty ? null : vm.cardType,
                items: const ['CNI', 'Passeport', 'Permis de conduire', 'Pas d\'ID'],
                onChanged: (v) => vm.setCardType(v!),
                validator: (v) => v == null ? 'Requis' : null,
              ),
              const SizedBox(height: 12),

              // TYPE DE VISITEUR
              _dropdown(
                hint: 'Type de visiteur',
                value: vm.visitorType.isEmpty ? null : vm.visitorType,
                items: const ['Visiteur', 'Employé', 'Invité'],
                onChanged: (v) => vm.setVisitorType(v!),
                validator: (v) => v == null ? 'Requis' : null,
              ),
              const SizedBox(height: 12),

              // NOMBRE DE VISITEURS
              _dropdown(
                hint: 'Nombre de visiteurs',
                value: vm.visitorCount.toString(),
                items: const ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
                onChanged: (v) => vm.setVisitorCount(int.parse(v!)),
              ),
              const SizedBox(height: 12),

              // ENTREPRISE (optionnel)
              _field(
                hint: 'Entreprise (optionnel)',
                onChanged: vm.setCompany,
              ),

              const SizedBox(height: 32),

              // ── Boutons Annuler / Confirmer ────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Annuler
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _onCancel,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: kRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 28),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('Annuler',
                          style: TextStyle(fontSize: 13, color: kGrey)),
                    ],
                  ),

                  const SizedBox(width: 60),

                  // Confirmer
                  Column(
                    children: [
                      GestureDetector(
                        onTap: vm.isLoading ? null : _onConfirm,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: vm.isLoading
                                ? kGreen.withOpacity(0.5)
                                : kGreen,
                            shape: BoxShape.circle,
                          ),
                          child: vm.isLoading
                              ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                              : const Icon(Icons.check,
                              color: Colors.white, size: 28),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('Confirmer',
                          style: TextStyle(fontSize: 13, color: kGrey)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widget champ texte ─────────────────────────────────────────────────────

  Widget _field({
    TextEditingController? controller,
    required String hint,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kRed),
        ),
      ),
    );
  }

  // ── Widget dropdown ────────────────────────────────────────────────────────

  Widget _dropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kRed),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }
}