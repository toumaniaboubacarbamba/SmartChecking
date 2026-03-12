class Visitor {
  final String? id;
  final String? lastName;
  final String? firstName;
  final String? docNumber;
  final String? docType;
  final String? birthDate;
  final String? expiryDate;
  final String scannedBy; //id de l'utilisateur qui a scanné
  final DateTime scannedAt;

  const Visitor({
    this.id,
    this.lastName,
    this.firstName,
    this.docNumber,
    this.docType,
    this.birthDate,
    this.expiryDate,
    required this.scannedBy,
    required this.scannedAt,
  });
}
