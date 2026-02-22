import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool renameToMovieName;

  const SettingsState({
    this.renameToMovieName = false,
  });

  SettingsState copyWith({
    bool? renameToMovieName,
  }) {
    return SettingsState(
      renameToMovieName: renameToMovieName ?? this.renameToMovieName,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const _keyRenameToMovieName = 'rename_to_movie_name';
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(SettingsState(
    renameToMovieName: _prefs.getBool(_keyRenameToMovieName) ?? false,
  ));

  Future<void> setRenameToMovieName(bool value) async {
    await _prefs.setBool(_keyRenameToMovieName, value);
    state = state.copyWith(renameToMovieName: value);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});
