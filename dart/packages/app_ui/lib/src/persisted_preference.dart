import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A choice kept on the device (language, colour theme, last used filter) and exposed as Riverpod state.
///
/// One notifier for every choice kept on the device (language, theme palette, remembered filter). Behaviour:
///  - the state is the [initial] value until the stored one is read;
///  - a choice made before the reading ends wins over the stored value;
///  - storage failures (private browsing, tests) never break the app: the choice simply is not remembered.
class PersistedPreference<T> extends StateNotifier<T> {
  PersistedPreference({
    required this.storageKey,
    required T initial,
    required this.decode,
    required this.encode,
  }) : super(initial) {
    _load();
  }

  /// Key in the device preferences.
  final String storageKey;

  /// Stored text -> value; null means "unusable", the initial value is kept.
  final T? Function(String stored) decode;

  /// Value -> stored text; null removes the stored value.
  final String? Function(T value) encode;

  bool _chosen = false;

  Future<void> _load() async {
    try {
      final stored = (await SharedPreferences.getInstance()).getString(storageKey);
      final value = stored == null ? null : decode(stored);
      if (!_chosen && mounted && value != null) state = value;
    } catch (_) {
      // No storage: the preference works, it is just not remembered.
    }
  }

  /// Applies the choice and remembers it.
  Future<void> choose(T value) async {
    _chosen = true;
    state = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      final text = encode(value);
      if (text == null) {
        await prefs.remove(storageKey);
      } else {
        await prefs.setString(storageKey, text);
      }
    } catch (_) {
      // See _load.
    }
  }
}

/// Last choice of a filter (period, vehicle...) kept on the device so it is found again at the next launch.
///
/// The state is null while nothing is remembered: the page then applies its own default. Each filter has its
/// own key (`stats-period`, `history-vehicle`...); the value is a plain text. Choosing null forgets it.
final rememberedFilterProvider =
    StateNotifierProvider.family<PersistedPreference<String?>, String?, String>(
  (ref, key) => PersistedPreference<String?>(
    storageKey: 'filter:$key',
    initial: null,
    decode: (stored) => stored,
    encode: (value) => value,
  ),
);

/// Interface language chosen by the user, kept on the device (even offline).
///
/// [initial] is the language used until the stored one is read (typically the device language, normalised with
/// `LanguageSupport.normalize`); [supported] filters out a stored code the app no longer offers.
StateNotifierProvider<PersistedPreference<String>, String> languagePreferenceProvider({
  required String initial,
  required List<String> supported,
}) =>
    StateNotifierProvider<PersistedPreference<String>, String>(
      (ref) => PersistedPreference<String>(
        storageKey: 'language',
        initial: initial,
        decode: (stored) => supported.contains(stored) ? stored : null,
        encode: (value) => value,
      ),
    );
