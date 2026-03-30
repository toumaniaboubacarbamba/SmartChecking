import 'package:flutter/foundation.dart';
import 'package:smart_checking/engines/auth_manager.dart';
import 'package:smart_checking/engines/visitor_manager.dart';
import 'package:smart_checking/entities/visitor.dart';
import 'package:smart_checking/models/errors.dart';
import 'package:smart_checking/models/visitorModel.dart';
import 'package:smart_checking/services/api.dart';
import 'package:smart_checking/services/ocr_service.dart';

enum OcrState {
  initial,
  scanning,
  done,
  error,
}

class VisitorViewModel extends ChangeNotifier {
  final VisitorManager _visitorManager;
  final AuthManager _authManager;
  final OcrService _ocrService;
  final ApiService _api; // ← ajout pour les exports

  OcrState _ocrState = OcrState.initial;
  Map<String, String?> _ocrResult = {};
  String _searchQuery = '';

  String _lastName = '';
  String _firstName = '';
  String _email = '';
  String _phone = '';
  String _gender = 'Masculin';
  String _visitReason = '';
  String _cardType = 'CNI';
  String _visitorType = 'Visiteur';
  String _entryMethod = 'Scan ID';
  String? _photoPath;
  String? _company;
  int _visitorCount = 1;

  // Erreur locale pour les exports
  AppException? _exportError;

  VisitorViewModel({
    required VisitorManager visitorManager,
    required AuthManager authManager,
    required OcrService ocrService,
    required ApiService api, // ← ajout
  })  : _visitorManager = visitorManager,
        _authManager = authManager,
        _ocrService = ocrService,
        _api = api {
    _visitorManager.addListener(_onVisitorChanged);
  }

  // ── Getters état liste ────────────────────────────────────────────────────

  VisitorState get visitorState => _visitorManager.state;
  bool get isLoading => _visitorManager.isLoading;
  int get totalVisitors => _visitorManager.totalVisitors;

  // On expose l'erreur du manager OU l'erreur export locale
  AppException? get error => _visitorManager.error ?? _exportError;

  List<Visitor> get visitors {
    if (_searchQuery.trim().isEmpty) return _visitorManager.visitors;
    return _visitorManager.search(_searchQuery);
  }

  // ── Getters OCR ───────────────────────────────────────────────────────────

  OcrState get ocrState => _ocrState;
  bool get isScanning => _ocrState == OcrState.scanning;
  Map<String, String?> get ocrResult => _ocrResult;

  // ── Getters recherche ─────────────────────────────────────────────────────

  String get searchQuery => _searchQuery;

  // ── Getters formulaire ────────────────────────────────────────────────────

  String get lastName => _lastName;
  String get firstName => _firstName;
  String get email => _email;
  String get phone => _phone;
  String get gender => _gender;
  String get visitReason => _visitReason;
  String get cardType => _cardType;
  String get visitorType => _visitorType;
  String get entryMethod => _entryMethod;
  String? get photoPath => _photoPath;
  String? get company => _company;
  int get visitorCount => _visitorCount;

  bool get isFormValid =>
      _lastName.trim().isNotEmpty &&
      _firstName.trim().isNotEmpty &&
      _gender.isNotEmpty &&
      _visitReason.trim().isNotEmpty &&
      _cardType.isNotEmpty &&
      _visitorType.isNotEmpty &&
      _entryMethod.isNotEmpty;

  // ── Setters formulaire ────────────────────────────────────────────────────

  void setLastName(String v)      { _lastName = v;    notifyListeners(); }
  void setFirstName(String v)     { _firstName = v;   notifyListeners(); }
  void setEmail(String v)         { _email = v;        notifyListeners(); }
  void setPhone(String v)         { _phone = v;        notifyListeners(); }
  void setGender(String v)        { _gender = v;       notifyListeners(); }
  void setVisitReason(String v)   { _visitReason = v;  notifyListeners(); }
  void setCardType(String v)      { _cardType = v;     notifyListeners(); }
  void setVisitorType(String v)   { _visitorType = v;  notifyListeners(); }
  void setEntryMethod(String v)   { _entryMethod = v;  notifyListeners(); }
  void setPhotoPath(String? v)    { _photoPath = v;    notifyListeners(); }
  void setCompany(String? v)      { _company = v;      notifyListeners(); }
  void setVisitorCount(int v)     { _visitorCount = v; notifyListeners(); }

  // ── Recherche ─────────────────────────────────────────────────────────────

  void setSearchQuery(String query) { _searchQuery = query; notifyListeners(); }
  void clearSearch()                { _searchQuery = '';    notifyListeners(); }

  // ── OCR ───────────────────────────────────────────────────────────────────

  Future<void> scanDocument(String imagePath) async {
    _ocrState = OcrState.scanning;
    _ocrResult = {};
    notifyListeners();

    try {
      final result = await _ocrService.extractFromImage(imagePath);
      _ocrResult = result;
      if (result['lastName'] != null)  _lastName  = result['lastName']!;
      if (result['firstName'] != null) _firstName = result['firstName']!;
      if (result['gender'] != null)    _gender    = result['gender']!;
      _entryMethod = 'Scan ID';
      _ocrState = OcrState.done;
    } catch (e) {
      _ocrState = OcrState.error;
    }

    notifyListeners();
  }

  void resetOcr() {
    _ocrState = OcrState.initial;
    _ocrResult = {};
    notifyListeners();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> fetchVisitors() async {
    final token = _authManager.currentAccount?.token;
    if (token == null) return;
    await _visitorManager.fetchVisitors(token);
  }

  Future<bool> submitVisitor() async {
    if (!isFormValid) return false;
    final token = _authManager.currentAccount?.token;
    if (token == null) return false;

    final visitor = VisitorModel(
      id: '',
      lastName: _lastName.trim(),
      firstName: _firstName.trim(),
      email: _email.trim().isEmpty ? null : _email.trim(),
      phone: _phone.trim().isEmpty ? null : _phone.trim(),
      gender: _gender,
      visitReason: _visitReason.trim(),
      cardType: _cardType,
      visitorType: _visitorType,
      photoPath: _photoPath,
      entryMethod: _entryMethod,
      entryTime: DateTime.now(),
      visitorCount: _visitorCount,
      company: _company?.trim().isEmpty ?? true ? null : _company?.trim(),
    );

    final success = await _visitorManager.addVisitor(token, visitor);
    if (success) resetForm();
    return success;
  }

  Future<bool> deleteVisitor(String visitorId) async {
    final token = _authManager.currentAccount?.token;
    if (token == null) return false;
    return _visitorManager.removeVisitor(token, visitorId);
  }

  Visitor? getVisitorById(String id) => _visitorManager.findById(id);

  // ── Export ────────────────────────────────────────────────────────────────

  Future<String?> exportCsv(List<String> ids) async {
    final token = _authManager.currentAccount?.token;
    if (token == null) return null;
    try {
      _exportError = null;
      return await _api.exportCsv(token, ids);
    } on AppException catch (e) {
      _exportError = e;
      notifyListeners();
      return null;
    }
  }

  Future<String?> exportPdf(List<String> ids) async {
    final token = _authManager.currentAccount?.token;
    if (token == null) return null;
    try {
      _exportError = null;
      return await _api.exportPdf(token, ids);
    } on AppException catch (e) {
      _exportError = e;
      notifyListeners();
      return null;
    }
  }

  // ── Reset formulaire ──────────────────────────────────────────────────────

  void resetForm() {
    _lastName = '';
    _firstName = '';
    _email = '';
    _phone = '';
    _gender = 'Masculin';
    _visitReason = '';
    _cardType = 'CNI';
    _visitorType = 'Visiteur';
    _entryMethod = 'Scan ID';
    _photoPath = null;
    _company = null;
    _visitorCount = 1;
    resetOcr();
    notifyListeners();
  }

  // ── Propagation ───────────────────────────────────────────────────────────

  void _onVisitorChanged() { notifyListeners(); }

  @override
  void dispose() {
    _visitorManager.removeListener(_onVisitorChanged);
    _ocrService.dispose();
    super.dispose();
  }
}