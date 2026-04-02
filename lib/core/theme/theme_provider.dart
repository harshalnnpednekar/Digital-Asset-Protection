import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

final isDarkProvider = Provider<bool>((ref) {
  return ref.watch(themeModeProvider) == ThemeMode.dark;
});
