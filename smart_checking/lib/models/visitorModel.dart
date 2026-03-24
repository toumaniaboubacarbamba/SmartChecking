import 'package:smart_checking/entities/visitor.dart';

class VisitorModel extends Visitor {
  const VisitorModel({
    required super.id,
    required super.lastName,
    required super.firstName,
    super.email,
    super.phone,
    required super.gender, //male ou femelle
    required super.visitReason,
    required super.cardType,
    required super.visitorType,
    super.photoPath,
    required super.entryMethod,
    required super.entryTime,
    super.exitTime,
    super.visitorCount,
    super.company,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) => VisitorModel(
    id: json['id'].toString(),
    lastName: json['last_name'] as String,
    firstName: json['first_name'] as String,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    gender: json['gender'] as String,
    visitReason: json['visit_reason'] as String,
    cardType: json['card_type'] as String,
    visitorType: json['visitor_type'] as String,
    photoPath: json['photo_path'] as String?,
    entryMethod: json['entry_method'] as String,
    entryTime: DateTime.parse(json['entry_time'] as String),
    exitTime: json['exit_time'] != null
        ? DateTime.parse(json['exit_time'] as String)
        : null,
    visitorCount: json['visitor_count'] as int? ?? 1,
    company: json['company'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'last_name': lastName,
    'first_name': firstName,
    'email': email,
    'phone': phone,
    'gender': gender,
    'visit_reason': visitReason,
    'card_type': cardType,
    'visitor_type': visitorType,
    'photo_path': photoPath,
    'entry_method': entryMethod,
    'entry_time': entryTime.toIso8601String(),
    'exit_time': exitTime?.toIso8601String(),
    'visitor_count': visitorCount,
    'company': company,
  };
}