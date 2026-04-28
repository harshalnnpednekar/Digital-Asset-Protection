// StorageService — Firebase Storage removed.
//
// File storage has been migrated to the Python backend's local disk
// (astra_backend/uploads/). The Flutter upload flow sends files directly
// to POST /process-asset via Dio multipart; this service is no longer
// called anywhere in the upload path.
//
// This stub exists only so the conditional export in storage_service.dart
// compiles cleanly on non-web platforms.

import 'package:flutter/foundation.dart';

class StorageService {
  Future<String?> uploadToVault(String filePath, String fileName) async {
    debugPrint('[StorageService] Firebase Storage removed — use backend /process-asset instead.');
    return null;
  }

  Future<String?> uploadToTemp(String filePath, String fileName) async {
    debugPrint('[StorageService] Firebase Storage removed — use backend /process-asset instead.');
    return null;
  }

  Future<List<String>> listVaultFiles() async => <String>[];

  Future<List<String>> listTempFiles() async => <String>[];

  Future<bool> deleteFromVault(String fileName) async => false;

  Future<bool> deleteFromTemp(String fileName) async => false;
}
