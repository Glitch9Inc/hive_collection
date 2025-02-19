// import 'dart:async';

// import '../../hive_collection.dart';

// class HiveMapRx<K, V> extends HiveMap<K, V> {
//   final _controller = StreamController<HiveMapEvent<K, V>>.broadcast();

//   HiveMapRx(super.boxName, {super.values});

//   Stream<HiveMapEvent<K, V>> get changes => _controller.stream;

//   @override
//   void operator []=(K key, V value) {
//     final oldValue = this[key];
//     super[key] = value;

//     if (oldValue == null) {
//       _controller.add(HiveMapEvent.added(key, value));
//     } else {
//       _controller.add(HiveMapEvent.updated(key, value));
//     }
//   }

//   @override
//   void remove(K key) {
//     final oldValue = this[key];
//     super.remove(key);

//     if (oldValue != null) {
//       _controller.add(HiveMapEvent.removed(key));
//     }
//   }

//   @override
//   void clear() {
//     final oldEntries = toMap();
//     super.clear();

//     for (final entry in oldEntries.entries) {
//       _controller.add(HiveMapEvent.removed(entry.key));
//     }
//   }

//   @override
//   void addAll(Map<K, V> entries) {
//     final oldEntries = toMap();
//     super.addAll(entries);

//     for (final entry in entries.entries) {
//       final key = entry.key;
//       final value = entry.value;

//       if (!oldEntries.containsKey(key)) {
//         _controller.add(HiveMapEvent.added(key, value));
//       } else {
//         _controller.add(HiveMapEvent.updated(key, value));
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _controller.close();
//     super.dispose();
//   }

//   void addListener(void Function(HiveMapEvent<K, V> event) listener) {
//     changes.listen(listener);
//   }

//   void removeListener(void Function(HiveMapEvent<K, V> event) listener) {
//     changes.listen(listener);
//   }
// }

// class HiveMapEvent<K, V> {
//   final HiveEventType type;
//   final K key;
//   final V? value;

//   HiveMapEvent._(this.type, this.key, this.value);

//   factory HiveMapEvent.added(K key, V value) => HiveMapEvent._(HiveEventType.added, key, value);
//   factory HiveMapEvent.updated(K key, V value) => HiveMapEvent._(HiveEventType.updated, key, value);
//   factory HiveMapEvent.removed(K key) => HiveMapEvent._(HiveEventType.removed, key, null);
// }
