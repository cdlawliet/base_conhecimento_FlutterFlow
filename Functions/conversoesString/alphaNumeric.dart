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

/// Remove todos os caracteres não alfanuméricos de uma string.
/// 
/// Esta função recebe uma string [inputString] e retorna uma nova string contendo
/// apenas letras (a-z, A-Z) e números (0-9). É ideal para remover máscaras
/// de CPF, CNPJ, telefones, CEPs, ou qualquer formatação que inclua
/// espaços, traços, pontos ou outros símbolos.
String? alphaNumeric(String? inputString) {
  /// MODIFY CODE ONLY BELOW THIS LINE

  if (inputString == null || inputString.isEmpty) {
    return '';
  }

  // Remove qualquer caractere que NÃO seja letra (a-z, A-Z) ou número (0-9)
  // Isso inclui remover espaços, traços, parênteses e outros símbolos de máscara.
  return inputString.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

  /// MODIFY CODE ONLY ABOVE THIS LINE
}
