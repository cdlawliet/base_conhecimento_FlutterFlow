// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'dart:typed_data';

Future<String?> relatPrint(FFUploadedFile? pdfFile) async {
  // Add your function code here!
  try {
    if (pdfFile == null || pdfFile.bytes == null) {
      return 'Arquivo PDF inválido ou não fornecido.';
    }

    final Uint8List pdfBytes = Uint8List.fromList(pdfFile.bytes!);

    // Tenta imprimir
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );

    return null; // Sucesso
  } catch (e) {
    print('Erro ao tentar imprimir: $e');
    return 'Falha ao tentar imprimir o PDF. Verifique se o dispositivo tem suporte à impressão.\nErro: ${e.toString()}';
  }
}
