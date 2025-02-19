import 'dart:async';

import '../hive_collection.dart';

class HiveListRx<T> extends HiveList<T> {
  final _controller = StreamController<HiveListEvent<T>>.broadcast();

  HiveListRx(super.boxName, {super.values});

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
  void removeAt(int index) {
    final oldValue = this[index];
    super.removeAt(index);

    if (oldValue != null) {
      _controller.add(HiveListEvent.removed(index));
    }
  }

  @override
  void clear() {
    final oldList = toList();
    super.clear();

    for (int i = 0; i < oldList.length; i++) {
      _controller.add(HiveListEvent.removed(i));
    }
  }

  @override
  void addAll(Iterable<T> values) {
    final oldList = toList();
    super.addAll(values);

    for (int i = 0; i < values.length; i++) {
      final value = values.elementAt(i);

      if (!oldList.contains(value)) {
        _controller.add(HiveListEvent.added(i, value));
      } else {
        _controller.add(HiveListEvent.updated(i, value));
      }
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
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
