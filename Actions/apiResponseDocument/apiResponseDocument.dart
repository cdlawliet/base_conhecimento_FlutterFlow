// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<FFUploadedFile> apiResponseDocument(
  String binaryData,
  String fileName,
) async {
  // Add your function code here!
  try {
    // Converte a String para lista de bytes (códigos de caracteres)
    final bytes = binaryData.codeUnits; // Isso preserva os bytes originais

    return FFUploadedFile(
      name: fileName,
      bytes: Uint8List.fromList(bytes), // Converte para Uint8List
    );
  } catch (e) {
    print('Error creating PDF: $e');
    throw Exception('PDF creation failed: $e');
  }
}