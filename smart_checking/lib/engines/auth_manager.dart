import 'package:flutter/foundation.dart';
import 'package:smart_checking/entities/account.dart';
import 'package:smart_checking/models/errors.dart';
import 'package:smart_checking/services/api.dart';
import 'package:smart_checking/services/storageService.dart';

//Etats possibles de l'authentification
enum AuthState{
  initial, //initialisation
  loading, // Chargement login, logout...
  authenticated, // Authentification réussie
  unauthenticated, // Authentification déconnecté
  error, // Erreur réseau ou login/mdp incorrect
}

//Gère l'état d'auth global de l'application
//utilisé comme ChangeNotifier injecté en haut de l'arbre de widgets.
class AuthManager extends ChangeNotifier {
  final ApiService _api;
  final Storageservice _storage;

  AuthState _state = AuthState.initial;
  Account? _currentAccount;
  AppException? _error;

  AuthManager({
    required ApiService api,
    required Storageservice storage,
  })  : _api = api,
        _storage = storage;

  // Getters
  AuthState get state => _state;
  Account? get currentAccount => _currentAccount;
  AppException? get error => _error;

  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  /// Token courant (extrait de l'account en mémoire)
  String? get _token => _currentAccount?.token;

//Init
// on l'appelle au démarrage de l'app pour restaurer la session save
  Future<void> initialize() async {
    _setState(AuthState.loading);

    try {
      final account = await _storage.getUser();

      if (account != null && account.token.isNotEmpty) {
        _currentAccount = account;
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (_) {
      _setState(AuthState.unauthenticated);
    }
  }

//Login retourne true en cas de succès et false...
  Future<bool> login(String email, String password) async {
    _setState(AuthState.loading);
    _clearError();

    try {
      final userModel = await _api.login(email, password);

      // Persistance locale
      await _storage.saveUser(userModel);

      // Mise à jour de l'état en mémoire
      _currentAccount = userModel;
      _setState(AuthState.authenticated);

      return true;
    } on AppException catch (e) {
      _error = e;
      _setState(AuthState.error);
      return false;
    } catch (e) {
      _error = AppException(e.toString());
      _setState(AuthState.error);
      return false;
    }
  }

  // Logout et nettoie le stockage local.
  Future<void> logout() async {
    final token = _token;
    _setState(AuthState.loading);

    if (token != null) {
      try {
        await _api.logout(token);
      } catch (_) {
        // Erreur réseau ignorée : on déconnecte quand même localement
      }
    }

    await _clearSession();
  }


  // helpers privés
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> _clearSession() async {
    await _storage.clearUser();
    _currentAccount = null;
    _error = null;
    _setState(AuthState.unauthenticated);
  }
}
