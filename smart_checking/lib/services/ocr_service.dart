import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final _textRecognizer = TextRecognizer();

  //Extrait le texte d'une image de CNI/Passeport
  Future<Map<String, String?>> extractFromImage(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final recognizedText = await _textRecognizer.processImage(inputImage);

    final fullText = recognizedText.text;

    return {
      'fullText': fullText,
      'lastName': _extractLastName(fullText),
      'firstName':_extractFirstName(fullText),
      'gender': _extractGender(fullText),
      'birthDate': _extractBirthDate(fullText),
    };
  }

 String? _extractLastName(String text) {
    //Logique d'extracion du nom selon le format CNI ivoirienne
   final lines = text.split('\n');
   for (final line in lines){
     if(line.toUpperCase() == line && line.length > 2) {
       return line.trim();
     }
   }
   return null;
 }

  String? _extractFirstName(String text) {
    final lines = text.split('\n');
    if(lines.length > 1) return lines[1].trim();
  }

  String?  _extractGender(String text) {
    if (text.contains('M') || text.contains('Masculin')) return 'Masculin';
    if (text.contains('F') || text.contains('Féminin')) return 'Féminin';
    return null;
  }

  String? _extractBirthDate(String text) {
    final regex = RegExp(r'\d{2}/\d{2}/\d{4}');
    final match = regex.firstMatch(text);
    return match?.group(0);
  }

  void dispose(){
    _textRecognizer.close();
  }
}