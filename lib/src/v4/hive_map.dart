// import 'package:hive/hive.dart';

// /// #### Wrapper class for Hive Box to use it as a [Map].
// /// * You MUST register adapter before using this class.
// ///
// /// ```dart
// /// await HiveCollection.ensureInitialized();
// /// HiveCollection.registerAdapter(MyClass.fromJson);
// /// HiveMap<String, MyClass> myMap = HiveMap('myMap');
// /// ```
// ///
// /// #### Supported key types:
// /// * String
// /// * int
// /// * double
// /// * bool
// /// * Enum
// /// * DateTime
// class HiveMap<K, V> {
//   final String boxName;
//   final Box<V> _box;

//   // 생성자에서 Box를 열고 초기화
//   HiveMap(this.boxName, {Map<K, V>? values}) : _box = Hive.box<V>(name: boxName) {
//     if (values != null) {
//       addAll(values);
//     }
//   }

//   // Map-like operations
//   V? operator [](K key) {
//     try {
//       return _box.get(HiveMapKey.parse(key));
//     } catch (e) {
//       remove(key); // remove the key if it's corrupted
//       return null;
//     }
//   }

//   void operator []=(K key, V value) => _box.put(HiveMapKey.parse(key), value);

//   bool containsKey(K key) => _box.containsKey(HiveMapKey.parse(key));

//   int get length => _box.length;

//   Iterable<K> get keys => _box.keys.map((key) => HiveMapKey.revert<K>(key));

//   Iterable<V> get values sync* {
//     for (int i = 0; i < _box.length; i++) {
//       yield _box.getAt(i);
//     }
//   }

//   Iterable<MapEntry<K, V>> get entries sync* {
//     for (int i = 0; i < _box.length; i++) {
//       final rawKey = _box.keyAt(i);
//       if (rawKey == null) continue;

//       final key = HiveMapKey.revert<K>(rawKey);
//       final value = _box.getAt(i) as V?;

//       if (value != null) {
//         yield MapEntry(key, value);
//       }
//     }
//   }

//   Iterable<MapEntry<K2, V2>> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) convert) sync* {
//     for (int i = 0; i < _box.length; i++) {
//       final rawKey = _box.keyAt(i);
//       if (rawKey == null) continue;

//       // 키와 값 변환 처리
//       final key = HiveMapKey.revert<K>(rawKey);
//       final value = _box.getAt(i) as V?;

//       if (value != null) {
//         yield convert(key, value);
//       }
//     }
//   }

//   Map<K, V> toMap() {
//     Map<K, V> map = {};
//     for (final key in keys) {
//       final value = this[key];
//       if (value != null) {
//         map[key] = value;
//       }
//     }
//     return map;
//   }

//   void addAll(Map<K, V> entries) {
//     Map<String, V> hiveEntries = {};
//     for (final entry in entries.entries) {
//       hiveEntries[HiveMapKey.parse(entry.key)] = entry.value;
//     }
//     _box.putAll(hiveEntries);
//   }

//   // 값을 삭제
//   void remove(K key) {
//     _box.delete(HiveMapKey.parse(key));
//   }

//   // 전체 Map 데이터를 삭제
//   void clear() {
//     _box.clear();
//   }

//   void dispose() {
//     _box.close();
//   }
// }

// abstract class HiveMapKey {
//   static String parse<K>(K key) {
//     if (key is String) return key;
//     if (key is Enum) return key.name; // toString() 대신 name 사용
//     if (key is int || key is double || key is bool) return key.toString();
//     if (key is DateTime) return key.toIso8601String();
//     throw Exception('Unsupported key type');
//   }

//   static K revert<K>(String key) {
//     try {
//       if (K == String) {
//         return key as K;
//       } else if (K == int) {
//         return int.parse(key) as K;
//       } else if (K == double) {
//         return double.parse(key) as K;
//       } else if (K == DateTime) {
//         return DateTime.parse(key) as K;
//       } else if (K == bool) {
//         return (key == 'true') as K;
//       } else {
//         throw Exception('Unsupported key type');
//       }
//     } catch (e) {
//       throw Exception('Failed to revert key: $e');
//     }
//   }
// }
