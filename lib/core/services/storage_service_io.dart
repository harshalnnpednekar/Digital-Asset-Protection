import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadToVault(String filePath, String fileName) async {
    try {
      final ref = _storage.ref().child('vault/$fileName');
      await ref.putFile(File(filePath));
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading to vault: $e');
      return null;
    }
  }

  Future<String?> uploadToTemp(String filePath, String fileName) async {
    try {
      final ref = _storage.ref().child('temp/$fileName');
      await ref.putFile(File(filePath));
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading to temp: $e');
      return null;
    }
  }

  Future<List<String>> listVaultFiles() async {
    try {
      final ref = _storage.ref().child('vault');
      final listResult = await ref.listAll();
      return listResult.items.map((item) => item.name).toList();
    } catch (e) {
      debugPrint('Error listing vault files: $e');
      return [];
    }
  }

  Future<List<String>> listTempFiles() async {
    try {
      final ref = _storage.ref().child('temp');
      final listResult = await ref.listAll();
      return listResult.items.map((item) => item.name).toList();
    } catch (e) {
      debugPrint('Error listing temp files: $e');
      return [];
    }
  }

  Future<bool> deleteFromVault(String fileName) async {
    try {
      final ref = _storage.ref().child('vault/$fileName');
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting from vault: $e');
      return false;
    }
  }

  Future<bool> deleteFromTemp(String fileName) async {
    try {
      final ref = _storage.ref().child('temp/$fileName');
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting from temp: $e');
      return false;
    }
  }
}
