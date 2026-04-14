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

import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

Future shareFile(
  FFUploadedFile file,
  String fileName,
) async {
  // Add your function code here!
  try {
    // Verifica se o arquivo tem dados
    if (file.bytes == null || file.bytes!.isEmpty) {
      throw Exception('O arquivo está vazio');
    }

    final fullFileName = '${fileName}.pdf';

    if (kIsWeb) {
      // 🌐 Ambiente Web: Usa os bytes diretamente sem usar o file system
      await Share.shareXFiles(
        [
          XFile.fromData(
            file.bytes!,
            name: fullFileName,
            mimeType: 'application/pdf',
          )
        ],
        text: 'Pedido CD Tecnologia',
        subject: 'Compartilhando pedido',
      );
    } else {
      // 📱 Ambiente Nativo (Mobile/Desktop): Cria diretório temporário
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fullFileName';

      // Grava o arquivo temporário
      final File tempFile = File(filePath);
      await tempFile.writeAsBytes(file.bytes!);

      // Compartilha pelo path do arquivo
      await Share.shareXFiles(
        [XFile(filePath, mimeType: 'application/pdf')],
        text: 'Pedido CD Tecnologia',
        subject: 'Compartilhando pedido',
      );
    }
  } catch (e) {
    print('Erro ao compartilhar: $e');
    rethrow;
  }
}
