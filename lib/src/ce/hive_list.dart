import 'dart:async';

import 'package:hive_ce/hive.dart' hide HiveList, HiveCollection;

import '../../hive_collection.dart';

part 'hive_list_rx.dart';

/// #### Wrapper class for Hive Box to use it as a [List].
/// * You MUST register adapter before using this class.
///
/// ```dart
/// await HiveCollection.ensureInitialized();
/// HiveCollection.registerAdapter(MyClass.fromJson);
/// HiveList<MyClass> myList = HiveList('myList');
/// ```
///
class HiveList<T> {
  final Box<T> _box;

  HiveList._(this._box, List<T>? values) {
    if (values != null) {
      addAll(values);
    }
  }

  static Future<HiveList<T>> create<T>(String boxName, {List<T>? values}) async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        final box = await Hive.openBox<T>(boxName);
        return HiveList<T>._(box, values);
      } else {
        final box = Hive.box<T>(boxName);
        return HiveList<T>._(box, values);
      }
    } catch (e) {
      print('Failed to create HiveList: $e');
      rethrow;
    }
  }

  T? operator [](int index) {
    try {
      return _box.getAt(index);
    } catch (e) {
      return null;
    }
  }

  void operator []=(int index, T value) => _box.putAt(index, value);

  int get length => _box.length;

  Future<int> add(T value) => _box.add(value);

  Future<Iterable<int>> addAll(Iterable<T> values) => _box.addAll(values);

  Future<void> insert(int index, T value) async {
    final list = toList();
    list.insert(index, value); // 리스트의 원하는 위치에 삽입
    await clear();
    await addAll(list); // 다시 Hive에 저장
  }

  Future<void> removeAt(int index) => _box.deleteAt(index);

  Future<int> clear() => _box.clear();

  List<T> toList() {
    List<T> list = [];
    for (int i = 0; i < length; i++) {
      final value = _box.getAt(i);
      if (value != null) {
        list.add(value);
      } else {
        print('HiveList has null value at index $i. Removing it.');
        //removeAt(i);
      }
    }
    return list;
  }

  Future<void> dispose() => _box.close();

  Future<Iterable<int>> sort([int Function(T a, T b)? compare]) async {
    final list = toList();
    list.sort(compare);
    await clear();
    return await addAll(list);
  }

  Future<Iterable<int>> replaceAll(List<T> list) async {
    await clear();
    return await addAll(list);
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
