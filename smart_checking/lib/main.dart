import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_checking/engines/auth_manager.dart';
import 'package:smart_checking/engines/visitor_manager.dart';
import 'package:smart_checking/services/api.dart';
import 'package:smart_checking/services/ocr_service.dart';
import 'package:smart_checking/services/storageService.dart';
import 'package:smart_checking/ui/pages/home_page.dart';
import 'package:smart_checking/view_models/auth_view_model.dart';
import 'package:smart_checking/view_models/visitor_view_model.dart';
import 'package:smart_checking/ui/pages/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartCheckingApp());
}

class SmartCheckingApp extends StatelessWidget {
  const SmartCheckingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // On crée les services une seule fois ici
    final apiService     = ApiService();
    final storageService = StorageService();
    final ocrService     = OcrService();

    // On crée les engines en leur injectant les services
    final authManager    = AuthManager(api: apiService, storage: storageService);
    final visitorManager = VisitorManager(api: apiService);

    return MultiProvider(
      providers: [
        // ViewModels exposés à toute l'app
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authManager: authManager),
        ),
        ChangeNotifierProvider(
          create: (_) => VisitorViewModel(
            visitorManager: visitorManager,
            authManager: authManager,
            ocrService: ocrService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'SmartChecking',
        debugShowCheckedModeBanner: false,

        // Thème global de l'app
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0CC17C),
          ),
          fontFamily: 'Arial',
          useMaterial3: true,
        ),

        // Page de démarrage
        home: const HomePage(),
      ),
    );
  }
}