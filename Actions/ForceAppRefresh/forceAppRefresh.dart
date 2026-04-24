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

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

Future<String?> forceAppRefresh(
  bool clearTemporaryFiles,
  bool clearWebStorage,
) async {
  // Limpa caches em memoria usados pelo Flutter em qualquer plataforma.
  final imageCache = PaintingBinding.instance.imageCache;
  imageCache.clear();
  imageCache.clearLiveImages();

  if (kIsWeb) {
    try {
      final dynamic serviceWorker = html.window.navigator.serviceWorker;
      if (serviceWorker != null) {
        final registrations = await serviceWorker.getRegistrations();
        for (final registration in registrations) {
          await registration.unregister();
        }
      }
    } catch (_) {
      // Alguns navegadores/ambientes podem nao expor service workers.
    }

    try {
      final dynamic cacheStorage = html.window.caches;
      if (cacheStorage != null) {
        final cacheKeys = await cacheStorage.keys();
        for (final cacheKey in cacheKeys) {
          await cacheStorage.delete(cacheKey);
        }
      }
    } catch (_) {
      // CacheStorage pode nao estar disponivel em todos os cenarios.
    }

    if (clearWebStorage) {
      try {
        html.window.localStorage.clear();
      } catch (_) {}

      try {
        html.window.sessionStorage.clear();
      } catch (_) {}
    }

    final currentUri = Uri.base;
    final refreshedUri = currentUri.replace(
      queryParameters: <String, String>{
        ...currentUri.queryParameters,
        'ff_refresh': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );

    html.window.location.replace(refreshedUri.toString());
    return null;
  }

  if (clearTemporaryFiles) {
    try {
      final temporaryDirectory = await getTemporaryDirectory();
      await _deleteDirectoryChildren(temporaryDirectory);
    } catch (e) {
      return 'Falha ao limpar arquivos temporarios: $e';
    }
  }

  return null;
}

Future<void> _deleteDirectoryChildren(Directory directory) async {
  if (!await directory.exists()) {
    return;
  }

  await for (final entity in directory.list(followLinks: false)) {
    try {
      await entity.delete(recursive: true);
    } catch (_) {
      // Ignora arquivos bloqueados pelo sistema.
    }
  }
}
