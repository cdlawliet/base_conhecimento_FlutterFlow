import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:typed_data';

Future<FFUploadedFile> relatorios(dynamic dadosRelatorio) async {
  final pdf = pw.Document();
  final pageFormat = _mapPageFormat(dadosRelatorio);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: pageFormat,
      build: (context) {
        List<pw.Widget> content = [];

        // ============================
        // HEAD (dinâmico em colunas)
        // ============================
        if (dadosRelatorio['head'] != null) {
          for (var linha in dadosRelatorio['head']) {
            final cols = linha['columns'] ?? [];

            content.add(
              pw.Row(
                children: cols.map<pw.Widget>((col) {
                  return pw.Expanded(
                    child: pw.Container(
                      alignment: _mapPwAlignment(col['alignment']),
                      padding: const pw.EdgeInsets.only(bottom: 2),
                      child: pw.Text(
                        (col['text'] ?? '').toString(),
                        textAlign: _mapTextAlign(col['alignment']),
                        style: pw.TextStyle(
                          fontSize: (col['fontSize'] ?? 12).toDouble(),
                          fontWeight: _mapFontWeight(col['fontStyle']),
                          fontStyle: _mapFontStyle(col['fontStyle']),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }

          content.add(pw.SizedBox(height: 1));
          content.add(pw.Divider(thickness: 1));
          content.add(pw.SizedBox(height: 2));
        }

        // ============================
        // BODY
        // ============================
        if (dadosRelatorio['body'] != null) {
          final body = dadosRelatorio['body'];
          final columns = body['columns'];
          final rows = body['rows'];
          final bodyFooter = body['bodyFooter'];

          final showGrid = body['showGrid'] ?? true;

          final zebraEnabled = body['zebra']?['enabled'] ?? false;
          final zebraColorHex = body['zebra']?['color'] ?? "#EEEEEE";
          final zebraColor = PdfColor.fromInt(
            int.parse("0xFF${zebraColorHex.substring(1)}"),
          );

          // Normalizar linhas
          List<List<String>> normalizedRows = [];

          for (var row in rows) {
            if (row is List) {
              normalizedRows.add(row.map((e) => (e ?? '').toString()).toList());
            } else if (row is Map) {
              normalizedRows.add(
                columns.map((c) {
                  final colName = c['name'];
                  return row[colName]?.toString() ?? '';
                }).toList(),
              );
            } else {
              normalizedRows.add([(row ?? '').toString()]);
            }
          }

          // ALINHAMENTO POR COLUNA
          final Map<int, pw.Alignment> colAlignments = {};
          for (int i = 0; i < columns.length; i++) {
            final align = (columns[i]['alignment'] ?? 'left').toString();
            switch (align) {
              case 'center':
                colAlignments[i] = pw.Alignment.center;
                break;
              case 'right':
                colAlignments[i] = pw.Alignment.centerRight;
                break;
              default:
                colAlignments[i] = pw.Alignment.centerLeft;
            }
          }

          // MESMAS LARGURAS DE COLUNA
          final Map<int, pw.TableColumnWidth> colWidths = {};
          for (int i = 0; i < columns.length; i++) {
            colWidths[i] = const pw.FlexColumnWidth(1);
          }

          // TABELA PRINCIPAL
          content.add(
            pw.Table.fromTextArray(
              headers: columns
                  .map((c) => (c['name'] ?? '').toString())
                  .toList(),
              data: normalizedRows,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              border: showGrid ? pw.TableBorder.all() : pw.TableBorder(),
              cellAlignments: colAlignments,
              columnWidths: colWidths,
              headerDecoration: !showGrid
                  ? pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(width: 1)),
                    )
                  : null,
              rowDecoration: zebraEnabled
                  ? pw.BoxDecoration(color: PdfColors.white)
                  : null,
              oddRowDecoration: zebraEnabled
                  ? pw.BoxDecoration(color: zebraColor)
                  : null,
            ),
          );

          // BODY FOOTER (opcional)
          if (bodyFooter != null && bodyFooter is List) {
            final List<String> bf = bodyFooter
                .map((e) => (e ?? '').toString())
                .toList();

            content.add(pw.SizedBox(height: 0.5));
            content.add(pw.Divider(thickness: 1));
            content.add(pw.SizedBox(height: 0.5));

            content.add(
              pw.Table(
                border: showGrid ? pw.TableBorder.all() : pw.TableBorder(),
                columnWidths: colWidths,
                children: [
                  pw.TableRow(
                    children: List.generate(columns.length, (i) {
                      final text = i < bf.length ? bf[i] : '';
                      return pw.Container(
                        alignment: colAlignments[i] ?? pw.Alignment.centerLeft,
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0.5,
                        ),
                        child: pw.Text(
                          text,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          }

          content.add(pw.SizedBox(height: 1));
          content.add(pw.Divider(thickness: 1));
          content.add(pw.SizedBox(height: 2));
        }

        // ============================
        // FOOTER TRADICIONAL (dinâmico em colunas)
        // ============================
        if (dadosRelatorio['footer'] != null) {
          for (var linha in dadosRelatorio['footer']) {
            final cols = linha['columns'] ?? [];

            content.add(
              pw.Row(
                children: cols.map<pw.Widget>((col) {
                  return pw.Expanded(
                    child: pw.Container(
                      alignment: _mapPwAlignment(col['alignment']),
                      padding: const pw.EdgeInsets.only(top: 1),
                      child: pw.Text(
                        (col['text'] ?? '').toString(),
                        textAlign: _mapTextAlign(col['alignment']),
                        style: pw.TextStyle(
                          fontSize: (col['fontSize'] ?? 12).toDouble(),
                          fontWeight: _mapFontWeight(col['fontStyle']),
                          fontStyle: _mapFontStyle(col['fontStyle']),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }
        }

        return content;
      },
    ),
  );

  final bytes = await pdf.save();

  return FFUploadedFile(
    name: 'relatorio.pdf',
    bytes: Uint8List.fromList(bytes),
  );
}

// ============================
// Funções auxiliares
// ============================

pw.TextAlign _mapTextAlign(String? align) {
  switch (align) {
    case 'center':
      return pw.TextAlign.center;
    case 'right':
      return pw.TextAlign.right;
    default:
      return pw.TextAlign.left;
  }
}

pw.Alignment _mapPwAlignment(String? align) {
  switch (align) {
    case 'center':
      return pw.Alignment.center;
    case 'right':
      return pw.Alignment.centerRight;
    default:
      return pw.Alignment.centerLeft;
  }
}

pw.FontWeight _mapFontWeight(String? style) {
  if (style == 'bold') return pw.FontWeight.bold;
  return pw.FontWeight.normal;
}

pw.FontStyle _mapFontStyle(String? style) {
  if (style == 'italic') return pw.FontStyle.italic;
  return pw.FontStyle.normal;
}

PdfPageFormat _mapPageFormat(dynamic dadosRelatorio) {
  dynamic orientation = 'portrait';

  if (dadosRelatorio is Map) {
    final page = dadosRelatorio['page'];

    orientation =
        dadosRelatorio['orientation'] ??
        (page is Map ? page['orientation'] : null) ??
        'portrait';
  }

  switch (orientation.toString().toLowerCase()) {
    case 'landscape':
      return PdfPageFormat.a4.landscape;
    default:
      return PdfPageFormat.a4;
  }
}
