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

List<String> stringToArray(String? valor) {
  /// MODIFY CODE ONLY BELOW THIS LINE

  // Converte "01,02" em ["01", "02"] removendo espacos e itens vazios.
  if (valor == null || valor.trim().isEmpty) {
    return [];
  }

  return valor
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();

  /// MODIFY CODE ONLY ABOVE THIS LINE
}