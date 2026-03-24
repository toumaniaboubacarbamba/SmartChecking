import 'package:equatable/equatable.dart';

class Visitor extends Equatable {
  final String id;
  final String lastName;
  final String firstName;
  final String? email;
  final String? phone;
  final String gender;         // Masculin, Féminin
  final String visitReason;    // Motif de la visite
  final String cardType;       // CNI, Passeport, Permis...
  final String visitorType;    // Visiteur, Employé, Invité
  final String? photoPath;     // photo prise par caméra
  final String entryMethod;    // Scan ID, Entrée manuelle
  final DateTime entryTime;
  final DateTime? exitTime;
  final int visitorCount;      // Nombre de visiteurs
  final String? company;       // Nom de l'entreprise

  const Visitor({
    required this.id,
    required this.lastName,
    required this.firstName,
    this.email,
    this.phone,
    required this.gender,
    required this.visitReason,
    required this.cardType,
    required this.visitorType,
    this.photoPath,
    required this.entryMethod,
    required this.entryTime,
    this.exitTime,
    this.visitorCount = 1,
    this.company,
  });

  @override
  List<Object?> get props => [id];
}