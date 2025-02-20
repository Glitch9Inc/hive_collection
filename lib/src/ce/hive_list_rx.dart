part of 'hive_list.dart';

class HiveListRx<T> extends HiveList<T> {
  final _controller = StreamController<HiveListEvent<T>>.broadcast();

  HiveListRx._(Box<T> box, List<T>? values) : super._(box, values);

  static Future<HiveListRx<T>> create<T>(String boxName, {List<T>? values}) async {
    final box = await Hive.openBox<T>(boxName);
    return HiveListRx<T>._(box, values);
  }

  Stream<HiveListEvent<T>> get changes => _controller.stream;

  @override
  void operator []=(int index, T value) {
    final oldValue = this[index];
    super[index] = value;

    if (oldValue == null) {
      _controller.add(HiveListEvent.added(index, value));
    } else {
      _controller.add(HiveListEvent.updated(index, value));
    }
  }

  @override
  Future<void> removeAt(int index) async {
    final oldValue = this[index];
    await super.removeAt(index);

    if (oldValue != null) {
      _controller.add(HiveListEvent.removed(index));
    }
  }

  @override
  Future<int> clear() async {
    final oldList = toList();
    final result = await super.clear();

    for (int i = 0; i < oldList.length; i++) {
      _controller.add(HiveListEvent.removed(i));
    }

    return result;
  }

  @override
  Future<Iterable<int>> addAll(Iterable<T> values) async {
    final oldList = toList();
    final result = await super.addAll(values);

    for (int i = 0; i < values.length; i++) {
      final value = values.elementAt(i);

      if (!oldList.contains(value)) {
        _controller.add(HiveListEvent.added(i, value));
      } else {
        _controller.add(HiveListEvent.updated(i, value));
      }
    }

    return result;
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
    return await super.dispose();
  }

  void addListener(void Function(HiveListEvent<T> event) listener) {
    changes.listen(listener);
  }

  void removeListener(void Function(HiveListEvent<T> event) listener) {
    changes.listen(listener);
  }
}

class HiveListEvent<V> {
  final HiveEventType type;
  final int index;
  final V? value;

  HiveListEvent._(this.type, this.index, this.value);

  factory HiveListEvent.added(int index, V value) => HiveListEvent._(HiveEventType.added, index, value);
  factory HiveListEvent.updated(int index, V value) => HiveListEvent._(HiveEventType.updated, index, value);
  factory HiveListEvent.removed(int index) => HiveListEvent._(HiveEventType.removed, index, null);
}
