import 'package:equatable/equatable.dart';
class Account extends Equatable {
    final String id;
    final String name;
    final String email;
    final String role; // Vigile, Admin
    final String token;
    

    const Account({
      required this.id,
      required this.name,
      required this.email,
      required this.role,
      required this.token,
    });

    @override
    List<Object?> get props=> [id];
}
