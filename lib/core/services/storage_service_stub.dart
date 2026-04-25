import 'package:flutter/foundation.dart';

class StorageService {
  Future<String?> uploadToVault(String filePath, String fileName) async {
    debugPrint('StorageService.uploadToVault is unavailable on this platform.');
    return null;
  }

  Future<String?> uploadToTemp(String filePath, String fileName) async {
    debugPrint('StorageService.uploadToTemp is unavailable on this platform.');
    return null;
  }

  Future<List<String>> listVaultFiles() async {
    return <String>[];
  }

  Future<List<String>> listTempFiles() async {
    return <String>[];
  }

  Future<bool> deleteFromVault(String fileName) async {
    debugPrint(
        'StorageService.deleteFromVault is unavailable on this platform.');
    return false;
  }

  Future<bool> deleteFromTemp(String fileName) async {
    debugPrint(
        'StorageService.deleteFromTemp is unavailable on this platform.');
    return false;
  }
}
