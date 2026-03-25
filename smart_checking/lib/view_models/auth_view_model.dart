import 'package:flutter/foundation.dart';
import 'package:smart_checking/engines/auth_manager.dart';

// ViewModel de l'authentification Fait le pont entre AuthManager et les pages Login/Splash.
class AuthViewModel extends ChangeNotifier {
  final AuthManager _authManager;

  String _email = '';
  String _password = '';
  bool _obscurePassword = true;

  AuthViewModel({required AuthManager authManager})
      : _authManager = authManager {
    // On écoute AuthManager et on propage les changements aux widgets
    _authManager.addListener(_onAuthChanged);
  }

  // Getters état global

  AuthState get authState => _authManager.state;
  bool get isLoading => _authManager.isLoading;
  bool get isAuthenticated => _authManager.isAuthenticated;
  String? get errorMessage => _authManager.error?.message;

  // Getters formulaire

  String get email => _email;
  String get password => _password;
  bool get obscurePassword => _obscurePassword;

  bool get isFormValid =>
      _email.trim().isNotEmpty && _password.length >= 6;

  // Setters formulaire

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }


  // Lance le login. Retourne `true` si succès.
  Future<bool> login() async {
    if (!isFormValid) return false;
    return _authManager.login(_email.trim(), _password);
  }

  // Lance le logout.
  Future<void> logout() async {
    await _authManager.logout();
  }

  // Restaure la session au démarrage (appelé depuis SplashPage).
  Future<void> initialize() async {
    await _authManager.initialize();
  }


  void _onAuthChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _authManager.removeListener(_onAuthChanged);
    super.dispose();
  }
}