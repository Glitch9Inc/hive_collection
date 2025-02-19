library;

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

export 'src/hive_list.dart';
export 'src/hive_list_rx.dart';
export 'src/hive_map.dart';
export 'src/hive_map_rx.dart';

class HiveCollection {
  static List<String> registeredAdapterIds = [];

  static Future<void> ensureInitialized() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.defaultDirectory = dir.path;
  }

  static void registerAdapter<T>(T? Function(dynamic) fromJson) {
    final adapterId = T.toString();
    if (registeredAdapterIds.contains(adapterId)) {
      throw Exception(
          'Adapter for $adapterId type is already registered. If you want to register an adapter for the type with the same name, please refactor the type name.');
    }

    registeredAdapterIds.add(adapterId);
    Hive.registerAdapter(adapterId, fromJson);
  }

  HiveCollection._();
}

enum HiveEventType { added, updated, removed }
