import 'package:hive_ce/hive.dart';

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

  HiveList.internal(this._box, List<T>? values) {
    if (values != null) {
      addAll(values);
    }
  }

  static Future<HiveList<T>> create<T>(String boxName, {List<T>? values}) async {
    final box = await Hive.openBox<T>(boxName);
    return HiveList<T>.internal(box, values);
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

  void add(T value) {
    try {
      _box.add(value);
      print('Added value to HiveList. HiveList now has ${_box.length} items');
    } catch (e) {
      print('Failed to add value to HiveList: $e');
    }
  }

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
