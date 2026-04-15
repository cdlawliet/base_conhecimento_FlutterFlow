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

import 'dart:convert';
import 'dart:typed_data';
import '/flutter_flow/uploaded_file.dart';

Future<FFUploadedFile> base64ToDocument(
  String base64Data,
  String fileName,
) async {
  // Add your function code here!
  final cleanedBase64 =
      base64Data.contains(',') ? base64Data.split(',').last : base64Data;

  final bytes = base64Decode(cleanedBase64);

  return FFUploadedFile(
    name: fileName,
    bytes: Uint8List.fromList(bytes),
  );
}
