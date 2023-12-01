library shared_preferences_flutter_riverpod;

import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The type parameter `T` is the type of value that will
/// be persisted in [SharedPreferences].
///
/// To update the value, use the [update()] function.
/// Direct assignment to state cannot be used.
///
/// ```dart
/// await watch(booPrefProvider.notifier).update(v);
/// ```
///
class PrefNotifier<T> extends StateNotifier<T> {
  PrefNotifier(this.prefs, this.prefKey, this.defaultValue)
      : super(prefs.get(prefKey) as T? ?? defaultValue);

  SharedPreferences prefs;
  String prefKey;
  T defaultValue;

  /// Updates the value asynchronously.
  Future<T> update(T Function(T) updater) async {
    final value = updater(state);
    if (value is String) {
      await prefs.setString(prefKey, value);
    } else if (value is bool) {
      await prefs.setBool(prefKey, value);
    } else if (value is int) {
      await prefs.setInt(prefKey, value);
    } else if (value is double) {
      await prefs.setDouble(prefKey, value);
    } else if (value is List<String>) {
      await prefs.setStringList(prefKey, value);
    }
    super.state = value;
    return value;
  }

  /// Do not use the setter for state.
  /// Instead, use `await update(value).`
  @override
  set state(T value) {
    assert(false,
        "Don't use the setter for state. Instead use `await update(value)`.");
    Future(() async {
      await update((value) => value);
    });
  }
}

/// Returns the [Provider] that has access to the value of preferences.
///
/// Persist the value of the type parameter T type in SharedPreferences.
/// The argument [prefs] specifies an instance of SharedPreferences.
/// The arguments [prefKey] and [defaultValue] specify the key name and default
/// value of the preference.
///
/// ```dart
///
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   final prefs = await SharedPreferences.getInstance();
///
///   final booPrefProvider = createPrefProvider<bool>(
///     prefs: (_) => prefs,
///     prefKey: "boolValue",
///     defaultValue: false,
///   );
///
/// ```
///
/// When referring to a value, use it as you would a regular provider.
///
/// ```dart
///
///   Consumer(builder: (context, watch, _) {
///     final value = watch(booPrefProvider);
///
/// ```
///
/// To change the value, use the update() method.
///
/// ```dart
///
///   await watch(booPrefProvider.notifier).update(true);
///
/// ```
///
StateNotifierProvider<PrefNotifier<T>, T> createPrefProvider<T>({
  required SharedPreferences Function(Ref) prefs,
  required String prefKey,
  required T defaultValue,
}) {
  return StateNotifierProvider<PrefNotifier<T>, T>(
      (ref) => PrefNotifier<T>(prefs(ref), prefKey, defaultValue));
}

/// Converts the value of type parameter `T` to a String and persists
/// it in SharedPreferences.
///
/// To update the value, use the [update()] function.
/// Direct assignment to state cannot be used.
///
/// ```dart
/// await watch(mapPrefProvider.notifier).update(v);
/// ```
///
class MapPrefNotifier<T> extends StateNotifier<T> {
  MapPrefNotifier(this.prefs, this.prefKey, this.mapFrom, this.mapTo)
      : super(mapFrom(prefs.getString(prefKey)));

  SharedPreferences prefs;
  String prefKey;
  T Function(String?) mapFrom;
  String Function(T) mapTo;

  /// Updates the value asynchronously.
  Future<T> update(T Function(T) updater) async {
    final nv = updater(state);
    await prefs.setString(prefKey, mapTo(nv));
    super.state = nv;
    return nv;
  }

  /// Do not use the setter for state.
  /// Instead, use `await update(value).`
  @override
  set state(T value) {
    assert(false,
        "Don't use the setter for state. Instead use `await update(value)`.");
    Future(() async {
      await update((value) => value);
    });
  }
}

/// Returns a [Provider] that can access the preference with any type you want.
///
/// Persist to SharePreferences after converting to String.
/// The argument [prefs] specifies an instance of SharedPreferences.
/// The arguments [prefKey] and [defaultValue] specify the key name and default
/// value of the preference.
/// Specify how to convert from String to type T in [mapFrom].
/// Specifies how to convert from type T to String in [mapTo].
///
/// ```dart
///
/// enum EnumValues {
///   foo,
///   bar,
/// }
///
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   final prefs = await SharedPreferences.getInstance();
///
///   final enumPrefProvider = createMapPrefProvider<EnumValues>(
///     prefs: (_) => prefs,
///     prefKey: "enumValue",
///     mapFrom: (v) => EnumValues.values
///         .firstWhere((e) => e.toString() == v, orElse: () => EnumValues.foo),
///     mapTo: (v) => v.toString(),
///   );
///
/// ```
///
/// When referring to a value, use it as you would a regular provider.
///
/// ```dart
///
///   Consumer(builder: (context, watch, _) {
///     final value = watch(enumPrefProvider);
///
/// ```
///
/// To change the value, use the update() method.
///
/// ```dart
///
///   await watch(enumPrefProvider.notifier).update(EnumValues.bar);
///
/// ```
///
StateNotifierProvider<MapPrefNotifier<T>, T> createMapPrefProvider<T>({
  required SharedPreferences Function(Ref) prefs,
  required String prefKey,
  required T Function(String?) mapFrom,
  required String Function(T) mapTo,
}) {
  return StateNotifierProvider<MapPrefNotifier<T>, T>(
      (ref) => MapPrefNotifier<T>(prefs(ref), prefKey, mapFrom, mapTo));
}
