import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mrz_flutter/extensions/string.extension.dart';

class ProcessTextImage {
  static final textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  Future<bool> firstDetectingProcess(
    RecognizedText recognizedText,
  ) async {
    try {
      Iterable<Match> firstMatches =
          recognizedText.text.matches(firstLineregex);
      return firstMatches.length == 1;
    } catch (error) {
      debugPrint("Isolate process:  has error $error");
      return false;
    }
  }

  Future<String?>? photoTextProcess(
    InputImage message,
  ) async {
    try {
      RecognizedText recognizedText =
          await textRecognizer.processImage(message);

      List<String?> processLines = [];

      final lines = recognizedText.blocks
          .expand<TextLine>((block) => block.lines)
          .toList();

      int index = lines.indexWhere((line) => line.text.contains('ICCOL'));
      if (index >= 0) {
        processLines =
            lines.sublist(index, lines.length - 1).map((e) => e.text).toList();
      }

      if (processLines.length >= 3) {
        return processMrzText(processLines);
      }

      return null;
    } catch (error) {
      debugPrint("Isolate result:  has error $error");
      return null;
    }
  }

  String? processMrzText(
    List<String?> processLines,
  ) {
    try {
      if (processLines.length >= 3) {
        String firstLine =
            processLines.first?.replaceAll(' ', '').toUpperCase() ?? '';
        String secondLine =
            processLines[1]?.replaceAll(' ', '').toUpperCase() ?? '';
        String thirdLine =
            processLines[2]?.replaceAll(' ', '').toUpperCase() ?? '';

        //first line
        String typeDoc = firstLine.substring(0, 2);
        String countryCode = firstLine.substring(2, 5);

        //second line
        int indexGender = secondLine.indexOf(RegExp(r'[F]|[M]|[f]|[m]'));
        String regex = "[$countryCode]";
        int indexCol = secondLine.indexOf(RegExp(regex));
        int indexNuip = secondLine.indexOf(RegExp(r'[<]'));

        String expiryDate = secondLine.substring(indexGender + 1, indexCol - 1);
        expiryDate = expiryDate.formatMrzDate(isExpired: true).toString();
        String birthDate = secondLine.substring(0, indexGender - 1);
        birthDate = birthDate.formatMrzDate().toString();
        String gender = secondLine[indexGender];
        String fiscalNumber =
            secondLine.substring(indexCol + 3, indexNuip).replaceAll(' ', '');

        // third line

        String nameUser =
            thirdLine.removeExtraAngleBrackets().replaceAll('«', '');
        String result =
            "expiryDate: $expiryDate \ngender:$gender  \nbirthDate: $birthDate \nfiscalNumber: $fiscalNumber \nnameUser: $nameUser \ntypeDoc: $typeDoc \ncountryCode: $countryCode";
        return result;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Isolate process:  has error $e");
      return null;
    }
  }

  void dispose() {
    textRecognizer.close();
  }
}
