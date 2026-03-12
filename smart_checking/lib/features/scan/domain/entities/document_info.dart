class DocumentInfo {
  final String? lastName;
  final String? firstName;
  final String? docNumber;
  final String? docType; //ex: 'CNI', 'Passport', 'permis', 'Attestation'
  final String? birthDate;
  final String? expiryDate;
  final String? rawText; //texte brut OCR

  const DocumentInfo({
    this.lastName,
    this.firstName,
    this.docNumber,
    this.docType,
    this.birthDate,
    this.expiryDate,
    required this.rawText,
  });
}
