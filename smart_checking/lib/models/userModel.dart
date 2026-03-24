import 'package:smart_checking/entities/account.dart';

class Usermodel extends Account {

const Usermodel ({
  required super.id,
  required super.name,
  required super.email,
  required super.role,
  required super.token,
});

factory Usermodel.fromJson(Map<String, dynamic> json)=> Usermodel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  token: json['token'] as String,
);

Map<String, dynamic> toJson() => {
  'id': id,
  'name': name,
  'email': email,
  'role': role,
  'token': token,
};



}