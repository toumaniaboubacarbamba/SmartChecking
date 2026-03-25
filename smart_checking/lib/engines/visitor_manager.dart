import 'package:flutter/foundation.dart';
import 'package:smart_checking/entities/visitor.dart';
import 'package:smart_checking/models/errors.dart';
import 'package:smart_checking/models/visitorModel.dart';
import 'package:smart_checking/services/api.dart';

enum VisitorState {
  initial,   // Aucune donnée chargée
  loading,   // Chargement en cours (fetch, create, delete)
  loaded,    // Liste chargée avec succès
  success,   // Action (create/delete) réussie
  error,     // Erreur réseau ou serveur
}


//Gère l'état de la liste des visiteurs
//utilisé comme ChangeNotifier injecté en haut de l'arbre de widgets.
class VisitorManager extends ChangeNotifier {
  final ApiService _api;

  VisitorState _state = VisitorState.initial;
  List<Visitor> _visitors = [];
  AppException? _error;

  VisitorManager({required ApiService api}) : _api = api;

//Getters

VisitorState get state => _state;
List<Visitor> get visitors => List.unmodifiable(_visitors);
AppException? get error => _error;

bool get isLoading => _state == VisitorState.loading;
int get totalVisitors => _visitors.length;

//Fetch
//Chargement des données depuis le serveur
  Future<void> fetchVisitors(String token) async {
    _setState(VisitorState.loading);
    _clearError();

    try {
      final result = await _api.getVisitors(token);
      _visitors = result;
      _setState(VisitorState.loaded);
    } on AppException catch (e) {
      _error = e;
      _setState(VisitorState.error);
    } catch (e) {
      _error = AppException(e.toString());
      _setState(VisitorState.error);
    }
  }

//Création d'un nouveau visiteur return true en cas de succès ou false...
Future<bool> addVisitor(String token, VisitorModel visitor) async {
  _setState(VisitorState.loading);
  _clearError();
  try{
    final created = await _api.createVisitor(token, visitor);
    // Mise à jour locale
    _visitors = [created, ..._visitors];
    _setState(VisitorState.success);
    return true;
  } on AppException catch (e) {
    _error = e;
    _setState(VisitorState.error);
    return false;
  } catch (e) {
    _error = AppException(e.toString());
    _setState(VisitorState.error);
    return false;
  }
}

// Delete un visiteur par son id
  Future<bool> removeVisitor(String token, String visitorId) async {
    _setState(VisitorState.loading);
    _clearError();

    try {
      await _api.deleteVisitor(token, visitorId);
      // Mise à jour locale
      _visitors = _visitors.where((v) => v.id != visitorId).toList();
      _setState(VisitorState.success);
      return true;
    } on AppException catch (e) {
      _error = e;
      _setState(VisitorState.error);
      return false;
    } catch (e) {
      _error = AppException(e.toString());
      _setState(VisitorState.error);
      return false;
    }
  }

//Helpers locaux
  /// Recherche locale dans la liste déjà chargée (sans appel API).
  List<Visitor> search(String query) {
    if (query.trim().isEmpty) return List.unmodifiable(_visitors);
    final q = query.toLowerCase();
    return _visitors.where((v) {
      return v.firstName.toLowerCase().contains(q) ||
          v.lastName.toLowerCase().contains(q) ||
          (v.company?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  /// Trouve un visiteur par son id dans la liste locale.
  Visitor? findById(String id) {
    try {
      return _visitors.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }
//Helpers privés
void _setState(VisitorState newState){
  _state = newState;
  notifyListeners();
}

void _clearError(){
  _error = null;
}
}