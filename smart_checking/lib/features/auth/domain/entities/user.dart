class User {
  final String id;
  final String name;
  final String email;
  final String role; //'gardien' ou 'receptionniste
  final String token;

  User({required this.id, required this.name, required this.email, required this.role, required this.token});
}
