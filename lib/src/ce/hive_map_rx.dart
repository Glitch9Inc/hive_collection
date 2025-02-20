part of 'hive_map.dart';

class HiveMapRx<K, V> extends HiveMap<K, V> {
  final _controller = StreamController<HiveMapEvent<K, V>>.broadcast();

  // ignore: use_super_parameters
  HiveMapRx._(Box<V> box, Map<K, V>? values) : super._(box, values);

  static Future<HiveMapRx<K, V>> create<K, V>(String boxName, {Map<K, V>? values}) async {
    final box = await Hive.openBox<V>(boxName);
    return HiveMapRx<K, V>._(box, values);
  }

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
  Future<void> remove(K key) async {
    final oldValue = this[key];
    await super.remove(key);

    if (oldValue != null) {
      _controller.add(HiveMapEvent.removed(key));
    }
  }

  @override
  Future<int> clear() async {
    final oldEntries = toMap();
    final result = await super.clear();

    for (final entry in oldEntries.entries) {
      _controller.add(HiveMapEvent.removed(entry.key));
    }

    return result;
  }

  @override
  Future<void> addAll(Map<K, V> entries) async {
    final oldEntries = toMap();
    await super.addAll(entries);

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
  Future<void> dispose() async {
    await _controller.close();
    await super.dispose();
  }

  void addListener(void Function(HiveMapEvent<K, V> event) listener) {
    changes.listen(listener);
  }

  void removeListener(void Function(HiveMapEvent<K, V> event) listener) {
    changes.listen(listener);
  }
}

class HiveMapEvent<K, V> {
  final HiveEventType type;
  final K key;
  final V? value;

  HiveMapEvent._(this.type, this.key, this.value);

  factory HiveMapEvent.added(K key, V value) => HiveMapEvent._(HiveEventType.added, key, value);
  factory HiveMapEvent.updated(K key, V value) => HiveMapEvent._(HiveEventType.updated, key, value);
  factory HiveMapEvent.removed(K key) => HiveMapEvent._(HiveEventType.removed, key, null);
}
