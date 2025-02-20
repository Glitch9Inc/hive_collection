import 'dart:async';

import 'package:hive_ce/hive.dart' hide HiveList, HiveCollection;

import '../../hive_collection.dart';

part 'hive_map_rx.dart';

/// #### Wrapper class for Hive Box to use it as a [Map].
/// * You MUST register adapter before using this class.
///
/// ```dart
/// await HiveCollection.ensureInitialized();
/// HiveCollection.registerAdapter(MyClass.fromJson);
/// HiveMap<String, MyClass> myMap = HiveMap('myMap');
/// ```
///
/// #### Supported key types:
/// * String
/// * int
/// * double
/// * bool
/// * Enum
/// * DateTime
/// * Custom key type with registered key adapter
///
/// Unsupported key type will throw an exception
///
/// #### How to register key adapter:
/// ```dart
/// HiveCollection.registerKeyAdapter<MyClass>((key) => MyClass.fromString(key));
/// ```
///
class HiveMap<K, V> {
  //final String boxName;
  final Box<V> _box;

  // 생성자에서 Box를 열고 초기화
  HiveMap._(this._box, Map<K, V>? values) {
    if (values != null) {
      addAll(values);
    }
  }

  static Future<HiveMap<K, V>> create<K, V>(String boxName, {Map<K, V>? values}) async {
    if (!Hive.isBoxOpen(boxName)) {
      final box = await Hive.openBox<V>(boxName);
      return HiveMap<K, V>._(box, values);
    } else {
      final box = Hive.box<V>(boxName);
      return HiveMap<K, V>._(box, values);
    }
  }

  // Map-like operations
  V? operator [](K key) {
    try {
      return _box.get(HiveMapKey.parse(key));
    } catch (e) {
      remove(key); // remove the key if it's corrupted
      return null;
    }
  }

  void operator []=(K key, V value) => set(key, value);
  Future<void> set(K key, V value) => _box.put(HiveMapKey.parse(key), value);

  bool containsKey(K key) => _box.containsKey(HiveMapKey.parse(key));

  int get length => _box.length;

  Iterable<K> get keys => _box.keys.map((key) => HiveMapKey.revert<K>(key));

  Iterable<V> get values sync* {
    for (int i = 0; i < _box.length; i++) {
      final value = _box.getAt(i);
      if (value != null) {
        yield value;
      }
    }
  }

  Iterable<MapEntry<K, V>> get entries sync* {
    for (int i = 0; i < _box.length; i++) {
      final rawKey = _box.keyAt(i);
      if (rawKey == null) continue;

      final key = HiveMapKey.revert<K>(rawKey);
      final value = _box.getAt(i);

      if (value != null) {
        yield MapEntry(key, value);
      }
    }
  }

  Iterable<MapEntry<K2, V2>> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) sync* {
    for (int i = 0; i < _box.length; i++) {
      final rawKey = _box.keyAt(i);
      if (rawKey == null) continue;

      // 키와 값 변환 처리
      final key = HiveMapKey.revert<K>(rawKey);
      final value = _box.getAt(i);

      if (value != null) {
        yield convert(key, value);
      }
    }
  }

  Map<K, V> toMap() {
    Map<K, V> map = {};
    for (final key in keys) {
      final value = this[key];
      if (value != null) {
        map[key] = value;
      }
    }
    return map;
  }

  Future<void> addAll(Map<K, V> entries) {
    Map<String, V> hiveEntries = {};
    for (final entry in entries.entries) {
      hiveEntries[HiveMapKey.parse(entry.key)] = entry.value;
    }
    return _box.putAll(hiveEntries);
  }

  // 값을 삭제
  Future<void> remove(K key) {
    return _box.delete(HiveMapKey.parse(key));
  }

  // 전체 Map 데이터를 삭제
  Future<int> clear() {
    return _box.clear();
  }

  Future<void> dispose() {
    return _box.close();
  }
}

abstract class HiveMapKey {
  static String parse<K>(K key) {
    if (key is String) return key;
    if (key is Enum) return key.name; // toString() 대신 name 사용
    if (key is int || key is double || key is bool) return key.toString();
    if (key is DateTime) return key.toIso8601String();
    //throw Exception('Unsupported key type');
    return key.toString();
  }

  static K revert<K>(String key) {
    try {
      if (K == String) {
        return key as K;
      } else if (K == int) {
        return int.parse(key) as K;
      } else if (K == double) {
        return double.parse(key) as K;
      } else if (K == DateTime) {
        return DateTime.parse(key) as K;
      } else if (K == bool) {
        return (key == 'true') as K;
      } else {
        //throw Exception('Unsupported key type');
        if (HiveCollection.registeredKeyAdapters.containsKey(K.toString())) {
          final keyAdapter = HiveCollection.getKeyAdapter<K>();
          return keyAdapter(key);
        }

        throw Exception('Unsupported key type: $K');
      }
    } catch (e) {
      throw Exception('Failed to revert key: $e');
    }
  }
}
