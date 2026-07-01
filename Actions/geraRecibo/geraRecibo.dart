import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<FFUploadedFile> geraRecibo(
  String logo,
  String cliente,
  double valor,
  String motivo,
  String? assinatura,
) async {
  final pdf = pw.Document();
  final logoImage = await _loadLogo(logo);
  final signatureImage = _loadSignature(assinatura);
  final valorFormatado = _formatCurrencyPtBr(valor);
  final valorExtensoText = _valorPorExtenso(valor);
  final dataEmissao = _formatDatePtBr(DateTime.now());

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5.landscape,
      margin: const pw.EdgeInsets.all(20),
      build: (context) {
        return pw.ClipRRect(
          horizontalRadius: 12,
          verticalRadius: 12,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              border: pw.Border.all(
                color: PdfColor.fromInt(0xFFCBD5E1), // Slate 300
                width: 1.5,
              ),
            ),
            child: pw.Stack(
              children: [
                // Marca d'água centralizada ao fundo do card (sobre o fundo branco, mas atrás do texto)
                if (logoImage != null)
                  pw.Positioned.fill(
                    child: pw.Center(
                      child: pw.Opacity(
                        opacity: 0.10,
                        child: pw.Image(
                          logoImage,
                          width: 260,
                          height: 150,
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                // Conteúdo do recibo
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    // Barra superior colorida (Teal)
                    pw.Container(
                      height: 6,
                      color: PdfColor.fromInt(0xFF0D9488), // Teal 600
                    ),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            // Cabeçalho com Título e Badge de Valor
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      'RECIBO DE PAGAMENTO',
                                      style: pw.TextStyle(
                                        fontSize: 18,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromInt(0xFF1E293B), // Slate 800
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    pw.SizedBox(height: 2),
                                    pw.Text(
                                      'Emissão: $dataEmissao',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        color: PdfColor.fromInt(0xFF64748B), // Slate 500
                                      ),
                                    ),
                                  ],
                                ),
                                // Badge do Valor Formatado
                                pw.Container(
                                  decoration: pw.BoxDecoration(
                                    color: PdfColor.fromInt(0xFFCCFBF1), // Teal 100
                                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                                    border: pw.Border.all(
                                      color: PdfColor.fromInt(0xFF99F6E4), // Teal 200
                                      width: 1,
                                    ),
                                  ),
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: pw.Text(
                                    valorFormatado,
                                    style: pw.TextStyle(
                                      fontSize: 20,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColor.fromInt(0xFF0F766E), // Teal 700
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            pw.Divider(color: PdfColor.fromInt(0xFFE2E8F0), thickness: 1), // Slate 200
                            
                            // Texto principal do recibo
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(vertical: 8),
                              child: pw.RichText(
                                textAlign: pw.TextAlign.justify,
                                text: pw.TextSpan(
                                  style: pw.TextStyle(
                                    fontSize: 11.5,
                                    color: PdfColor.fromInt(0xFF334155), // Slate 700
                                    lineSpacing: 4.5,
                                  ),
                                  children: [
                                    const pw.TextSpan(text: 'Confirmamos o recebimento da importância de '),
                                    pw.TextSpan(
                                      text: valorFormatado,
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromInt(0xFF0F766E), // Teal 700
                                      ),
                                    ),
                                    if (valorExtensoText.isNotEmpty) ...[
                                      const pw.TextSpan(text: ' ('),
                                      pw.TextSpan(
                                        text: valorExtensoText,
                                        style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                                      ),
                                      const pw.TextSpan(text: ')'),
                                    ],
                                    const pw.TextSpan(text: ', paga por '),
                                    pw.TextSpan(
                                      text: cliente,
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromInt(0xFF1E293B), // Slate 800
                                      ),
                                    ),
                                    const pw.TextSpan(text: ', referente a '),
                                    pw.TextSpan(
                                      text: motivo,
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromInt(0xFF1E293B),
                                      ),
                                    ),
                                    const pw.TextSpan(
                                      text: ', pelo que damos plena, geral e irrevogável quitação.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Assinatura
                            pw.Column(
                              children: [
                                if (signatureImage != null)
                                  pw.Container(
                                    height: 40,
                                    width: 150,
                                    margin: const pw.EdgeInsets.only(bottom: 4),
                                    child: pw.Image(
                                      signatureImage,
                                      fit: pw.BoxFit.contain,
                                    ),
                                  ),
                                pw.Container(
                                  width: 200,
                                  height: 1,
                                  color: PdfColor.fromInt(0xFF94A3B8), // Slate 400
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  'Assinatura / Carimbo do Emitente',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    color: PdfColor.fromInt(0xFF64748B), // Slate 500
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  final bytes = await pdf.save();

  return FFUploadedFile(
    name: 'recibo_pagamento.pdf',
    bytes: Uint8List.fromList(bytes),
  );
}

Future<pw.MemoryImage?> _loadLogo(String logo) async {
  final logoUrl = logo.trim();
  if (logoUrl.isEmpty) {
    return null;
  }

  try {
    final response = await http.get(Uri.parse(logoUrl));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    return pw.MemoryImage(response.bodyBytes);
  } catch (_) {
    return null;
  }
}

pw.MemoryImage? _loadSignature(String? base64Str) {
  if (base64Str == null || base64Str.trim().isEmpty) {
    return null;
  }
  try {
    final cleaned = base64Str.contains(',') ? base64Str.split(',').last : base64Str;
    final bytes = base64Decode(cleaned.trim());
    return pw.MemoryImage(bytes);
  } catch (_) {
    return null;
  }
}

String _formatCurrencyPtBr(double value) {
  final isNegative = value < 0;
  final fixed = value.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final integer = parts[0];
  final decimal = parts[1];
  final buffer = StringBuffer();

  for (var i = 0; i < integer.length; i++) {
    final reverseIndex = integer.length - i;
    buffer.write(integer[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  final signal = isNegative ? '- ' : '';
  return '${signal}R\$ ${buffer.toString()},$decimal';
}

String _formatDatePtBr(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');

  return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
}

String _valorPorExtenso(double valor) {
  if (valor == 0) return 'zero reais';
  
  final valorAbs = valor.abs();
  final inteira = valorAbs.toInt();
  final centavos = ((valorAbs - inteira) * 100).round();
  
  final buffer = StringBuffer();
  
  if (inteira > 0) {
    buffer.write(_formatarGrande(inteira));
    if (inteira >= 1000000 && inteira % 1000000 == 0) {
      buffer.write(' de reais');
    } else {
      buffer.write(inteira == 1 ? ' real' : ' reais');
    }
  }
  
  if (centavos > 0) {
    if (inteira > 0) {
      buffer.write(' e ');
    }
    buffer.write(_converterInteiro(centavos));
    buffer.write(centavos == 1 ? ' centavo' : ' centavos');
  }
  
  return buffer.toString();
}

String _formatarGrande(int n) {
  if (n == 0) return 'zero';
  
  var resultado = '';
  final milhoes = n ~/ 1000000;
  var resto = n % 1000000;
  
  if (milhoes > 0) {
    if (milhoes == 1) {
      resultado += 'um milhão';
    } else {
      resultado += '${_converterInteiro(milhoes)} milhões';
    }
    if (resto > 0) {
      resultado += (resto < 100 || resto % 100 == 0) ? ' e ' : ', ';
    }
  }
  
  final milhares = resto ~/ 1000;
  resto = resto % 1000;
  
  if (milhares > 0) {
    if (milhares == 1) {
      resultado += 'mil';
    } else {
      resultado += '${_converterInteiro(milhares)} mil';
    }
    if (resto > 0) {
      resultado += (resto < 100 || resto % 100 == 0) ? ' e ' : ', ';
    }
  }
  
  if (resto > 0 || resultado.isEmpty) {
    if (resto > 0) {
      resultado += _converterInteiro(resto);
    }
  }
  
  return resultado;
}

String _converterInteiro(int n) {
  final unidades = ['zero', 'um', 'dois', 'três', 'quatro', 'cinco', 'seis', 'sete', 'oito', 'nove'];
  final dezenas1 = ['dez', 'onze', 'doze', 'treze', 'quatorze', 'quinze', 'dezesseis', 'dezessete', 'dezoito', 'dezenove'];
  final dezenas2 = ['', '', 'vinte', 'trinta', 'quarenta', 'cinquenta', 'sessenta', 'setenta', 'oitenta', 'noventa'];
  final centenas = ['', 'cento', 'duzentos', 'trezentos', 'quatrocentos', 'quinhentos', 'seiscentos', 'setecentos', 'oitocentos', 'novecentos'];

  if (n == 100) return 'cem';
  if (n < 10) return unidades[n];
  if (n < 20) return dezenas1[n - 10];
  if (n < 100) {
    final d = n ~/ 10;
    final u = n % 10;
    return u == 0 ? dezenas2[d] : '${dezenas2[d]} e ${unidades[u]}';
  }
  final c = n ~/ 100;
  final resto = n % 100;
  if (resto == 0) return centenas[c];
  return '${centenas[c]} e ${_converterInteiro(resto)}';
}
