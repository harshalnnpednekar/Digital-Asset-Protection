import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload file to vault folder
  Future<String?> uploadToVault(String filePath, String fileName) async {
    try {
      final ref = _storage.ref().child('vault/$fileName');
      await ref.putFile(File(filePath));
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading to vault: $e');
      return null;
    }
  }

  // Upload file to temp folder
  Future<String?> uploadToTemp(String filePath, String fileName) async {
    try {
      final ref = _storage.ref().child('temp/$fileName');
      await ref.putFile(File(filePath));
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading to temp: $e');
      return null;
    }
  }

  // List files in vault folder
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

  // List files in temp folder
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

  // Delete file from vault
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

  // Delete file from temp
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
