import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '/flutter_flow/custom_functions.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/uploaded_file.dart';
import '/backend/schema/structs/index.dart';

String applyMask(
  String? data,
  String? type,
) {
  /// MODIFY CODE ONLY BELOW THIS LINE

  if (data == null || data.isEmpty || type == null || type.isEmpty) {
    return data ?? '';
  }

  // Removemos qualquer máscara anterior para garantir que os dados estejam limpos
  String cleanData = data.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  if (cleanData.isEmpty) return data;

  switch (type.toLowerCase().trim()) {
    case 'cep':
      // Formato: 00.000-000
      if (cleanData.length != 8 || !RegExp(r'^[0-9]+$').hasMatch(cleanData)) {
        return data;
      }
      return '${cleanData.substring(0, 2)}.${cleanData.substring(2, 5)}-${cleanData.substring(5, 8)}';

    case 'telefone':
      // Formatos: (00) 0000-0000 ou (00) 0 0000-0000
      if ((cleanData.length != 10 && cleanData.length != 11) || !RegExp(r'^[0-9]+$').hasMatch(cleanData)) {
        return data;
      }
      if (cleanData.length == 10) {
        return '(${cleanData.substring(0, 2)}) ${cleanData.substring(2, 6)}-${cleanData.substring(6)}';
      }
      return '(${cleanData.substring(0, 2)}) ${cleanData.substring(2, 3)} ${cleanData.substring(3, 7)}-${cleanData.substring(7)}';

    case 'placa':
      // Formato: AAA-0000 (ou padrão Mercosul AAA-0A00)
      if (cleanData.length != 7) {
        return data;
      }
      String placa = cleanData.toUpperCase();
      return '${placa.substring(0, 3)}-${placa.substring(3, 7)}';

    default:
      // Se não reconhecer o tipo, retorna os dados originais
      return data;
  }

  /// MODIFY CODE ONLY ABOVE THIS LINE
}