import 'dart:async';

import 'package:hive/hive.dart';

/// You MUST register adapter before using this class.
/// You can register adapter by calling `Hive.registerAdapter(MyClass.fromJson)` before using this class.
class HiveMap<K, V> {
  final String boxName;
  final Box<V> _box;

  // 생성자에서 Box를 열고 초기화
  HiveMap(this.boxName, {Map<K, V>? values}) : _box = Hive.box<V>(name: boxName) {
    if (values != null) {
      addAll(values);
    }
  }

  // Map-like operations
  V? operator [](K key) {
    try {
      return _box.get(HiveMapKey.parse(key));
    } catch (e) {
      // remove the key if it's corrupted
      remove(key);
      return null;
    }
  }

  void operator []=(K key, V value) => _box.put(HiveMapKey.parse(key), value);

  bool containsKey(K key) => _box.containsKey(HiveMapKey.parse(key));

  int get length => _box.length;

  Iterable<K> get keys => _box.keys.map((key) => HiveMapKey.revert<K>(key));

  Iterable<V> get values sync* {
    for (int i = 0; i < _box.length; i++) {
      yield _box.getAt(i);
    }
  }

  Iterable<MapEntry<K, V>> get entries sync* {
    for (int i = 0; i < _box.length; i++) {
      final rawKey = _box.keyAt(i);
      if (rawKey == null) continue;

      final key = HiveMapKey.revert<K>(rawKey);
      final value = _box.getAt(i) as V?;

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
      final value = _box.getAt(i) as V?;

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

  void addAll(Map<K, V> entries) {
    Map<String, V> hiveEntries = {};
    for (final entry in entries.entries) {
      hiveEntries[HiveMapKey.parse(entry.key)] = entry.value;
    }
    _box.putAll(hiveEntries);
  }

  // 값을 삭제
  void remove(K key) {
    _box.delete(HiveMapKey.parse(key));
  }

  // 전체 Map 데이터를 삭제
  void clear() {
    _box.clear();
  }

  void dispose() {
    _box.close();
  }
}

class ReactiveHiveMap<K, V> extends HiveMap<K, V> {
  final _controller = StreamController<HiveMapEvent<K, V>>.broadcast();

  ReactiveHiveMap(String boxName, {Map<K, V>? values}) : super(boxName, values: values);

  Stream<HiveMapEvent<K, V>> get changes => _controller.stream;

  @override
  void operator []=(K key, V value) {
    final oldValue = this[key];
    super[key] = value;

    if (oldValue == null) {
      _controller.add(HiveMapEvent.added(key, value));
    } else {
      _controller.add(HiveMapEvent.updated(key, value));
    }
  }

  @override
  void remove(K key) {
    final oldValue = this[key];
    super.remove(key);

    if (oldValue != null) {
      _controller.add(HiveMapEvent.removed(key));
    }
  }

  @override
  void clear() {
    final oldEntries = toMap();
    super.clear();

    for (final entry in oldEntries.entries) {
      _controller.add(HiveMapEvent.removed(entry.key));
    }
  }

  @override
  void addAll(Map<K, V> entries) {
    final oldEntries = toMap();
    super.addAll(entries);

    for (final entry in entries.entries) {
      final key = entry.key;
      final value = entry.value;

      if (!oldEntries.containsKey(key)) {
        _controller.add(HiveMapEvent.added(key, value));
      } else {
        _controller.add(HiveMapEvent.updated(key, value));
      }
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void addListener(void Function(HiveMapEvent<K, V> event) listener) {
    changes.listen(listener);
  }

  void removeListener(void Function(HiveMapEvent<K, V> event) listener) {
    changes.listen(listener);
  }
}

class HiveList<T> {
  final String boxName;
  final Box<T> _box;

  HiveList(this.boxName, {List<T>? values}) : _box = Hive.box<T>(name: boxName) {
    if (values != null) {
      addAll(values);
    }
  }

  T? operator [](int index) {
    try {
      return _box.get(index.toString());
    } catch (e) {
      return null;
    }
  }

  void operator []=(int index, T value) => _box.putAt(index, value);

  int get length => _box.length;

  void add(T value) => _box.add(value);

  void addAll(Iterable<T> values) => _box.addAll(values);

  void insert(int index, T value) {
    final list = toList();
    list.insert(index, value); // 리스트의 원하는 위치에 삽입
    clear();
    addAll(list); // 다시 Hive에 저장
  }

  void removeAt(int index) => _box.deleteAt(index);

  void clear() => _box.clear();

  List<T> toList() {
    List<T> list = [];
    for (int i = 0; i < length; i++) {
      final value = this[i];
      if (value != null) {
        list.add(value);
      } else {
        removeAt(i);
      }
    }
    print('HiveList has ${list.length} (of $length / box length(${_box.length})) items');
    return list;
  }

  void dispose() {
    _box.close();
  }

  void sort([int Function(T a, T b)? compare]) {
    final list = toList();
    list.sort(compare);
    clear();
    addAll(list);
  }

  void replaceAll(List<T> list) {
    clear();
    addAll(list);
  }

  void forEach(void Function(T element) f) {
    for (int i = 0; i < length; i++) {
      final element = this[i];
      if (element != null) f(element);
    }
  }

  Iterable<T> where(bool Function(T element) test) sync* {
    for (int i = 0; i < length; i++) {
      final element = this[i];
      if (element != null && test(element)) {
        yield element;
      }
    }
  }

  Iterable<T2> map<T2>(T2 Function(T element) f) sync* {
    for (int i = 0; i < length; i++) {
      final element = this[i];
      if (element != null) yield f(element);
    }
  }

  T? firstWhere(bool Function(T element) test, {T Function()? orElse}) {
    for (int i = 0; i < length; i++) {
      final element = this[i];
      if (element != null && test(element)) {
        return element;
      }
    }
    return orElse?.call();
  }

  T? lastWhere(bool Function(T element) test, {T Function()? orElse}) {
    for (int i = length - 1; i >= 0; i--) {
      final element = this[i];
      if (element != null && test(element)) {
        return element;
      }
    }
    return orElse?.call();
  }

  bool contains(T element) {
    for (int i = 0; i < length; i++) {
      if (this[i] == element) {
        return true;
      }
    }
    return false;
  }
}

// 변경 이벤트 타입 정의
enum HiveEventType { added, updated, removed }

// HiveMap의 이벤트 모델
class HiveMapEvent<K, V> {
  final HiveEventType type;
  final K key;
  final V? value;

  HiveMapEvent._(this.type, this.key, this.value);

  factory HiveMapEvent.added(K key, V value) => HiveMapEvent._(HiveEventType.added, key, value);
  factory HiveMapEvent.updated(K key, V value) => HiveMapEvent._(HiveEventType.updated, key, value);
  factory HiveMapEvent.removed(K key) => HiveMapEvent._(HiveEventType.removed, key, null);
}

abstract class HiveMapKey {
  static String parse<K>(K key) {
    if (key is String) return key;
    if (key is Enum) return key.name; // toString() 대신 name 사용
    if (key is int || key is double || key is bool) return key.toString();
    if (key is DateTime) return key.toIso8601String();
    throw Exception('Unsupported key type');
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
        throw Exception('Unsupported key type');
      }
    } catch (e) {
      throw Exception('Failed to revert key: $e');
    }
  }
}
