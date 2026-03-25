import 'package:flutter/foundation.dart';
import 'package:smart_checking/engines/auth_manager.dart';
import 'package:smart_checking/engines/visitor_manager.dart';
import 'package:smart_checking/services/ocr_service.dart';

//Etats de l'OCR séparés de VisitorState pour ne pas bloquer l'UI pendant le scan
enum OcrState {
  initial,  // Pas de scan en cours
  scanning, // Scan OCR en cours
  done,     // Scan terminé avec succès
  error,    // Échec du scan
}

//Etats de la liste des visiteurs, le formulaire de création de visiteur, le scan OCR et la recherche
class VisitorViewModel extends ChangeNotifier{
  final VisitorManager _visitorManager;
  final AuthManager _authManager;
  final OcrService _ocrService;

  //Etat OCR
OcrState _ocrState = OcrState.initial;
Map<String, String?> _ocrResult = {};

//Etat recherche
String _searchQuery = '';
 //champs formulaire addVisitor
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
int visitorCount = 1;

VisitorViewModel({
  required VisitorManager visitorManager,
  required AuthManager authManager,
  required OcrService ocrService,
}) : _visitorManager = visitorManager,
    _authManager = authManager,
    _ocrService = ocrService{
  _visitorManager.addListener(_onVisitorChanged);
}

//Getters état liste

  VisitorState get visitorState => _visitorManager.state;
  bool get isLoading => _visitorManager.isLoading;
  AppException? get error => _visitorManager.error;
  int get totalVisitors => _visitorManager.totalVisitors;

  /// Liste filtrée selon la recherche en cours
  List<Visitor> get visitors {
    if (_searchQuery.trim().isEmpty) return _visitorManager.visitors;
    return _visitorManager.search(_searchQuery);
  }

  //Getters OCR
OcrState get ocrState => _ocrState;
  bool get isScanning => _ocrState == OcrState.scanning;
  Map<String, String?> get ocrResult => _ocrResult;

  // Getters recherche
String get searchQuery => _searchQuery;

//Getters formulaire

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

  //Formulaire valide si les champs obligatoires sont remplis
bool get isFormValid =>
    _lastName.trim().isNotEmpty &&
    _firstName.trim().isNotEmpty &&
    _gender.trim().isNotEmpty &&
    _visitReason.trim().isNotEmpty &&
    _cardType.isNotEmpty &&
    _visitorType.isNotEmpty &&
    _entryMethod.isNotEmpty;

//Setters formulaire

void setLastName(String v) {_lastName = v; notifyListeners();}
void setFirstName(String v) {_firstName = v; notifyListeners();}
void setEmail(String v) {_email = v; notifyListeners();}
void setPhone(String v) {_phone = v; notifyListeners();}
void setGender(String v) {_gender = v; notifyListeners();}
void setVisitReason(String v) {_visitReason = v; notifyListeners();}
void setCardType(String v) {_cardType = v; notifyListeners();}
void setVisitorType(String v) {_visitorType = v; notifyListeners();}
void setEntryMethod(String v) {_entryMethod = v; notifyListeners();}
void setPhotoPath(String? v) {_photoPath = v; notifyListeners();}
void setCompany(String? v) {_company = v; notifyListeners();}
void setVisitorCount(int v) {visitorCount = v; notifyListeners();}

// Setters Search
void setSearchQuery(String query) {
  _searchQuery = query;
  notifyListeners();
}
void clearSearch(){
  _searchQuery = '';
  notifyListeners();
}

//Scan OCRQuery
Future<void> scanOcr(String imagePath) async {
  _ocrState = OcrState.scanning;
  _ocrResult = {};
  notifyListeners();
  try {
    final result = await _ocrService.extractFromImage(imagePath);
    _ocrResult = result;
    //pré-remplissage des champs du formulaire
    if (result['lastName'] != null) _lastName = result['lastName']!;
    if (result['firstName'] != null) _firstName = result['firstName']!;
    if (result['gender'] != null) _gender = result['gender']!;

    _entryMethod = 'Scan ID';
    _ocrState = OcrState.done;
  } catch (e) {
    _ocrState = OcrState.error;
  }
  notifyListeners();
}
void resetOcr(){
  _ocrState = OcrState.initial;
  _ocrResult = {};
  notifyListeners();
}

//CRUD
  Future<void> fetchVisitors() async {
    final token = _authManager.currentAccount?.token;
    if (token == null) return;
    await _visitorManager.fetchVisitors(token);
  }
  
)

  }
}

}