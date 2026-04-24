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