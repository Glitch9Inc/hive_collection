library;

import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'src/utils/hive_collection_adapter.dart';

/*
export 'src/v4/hive_list.dart';
export 'src/v4/hive_list_rx.dart';
export 'src/v4/hive_map.dart';
export 'src/v4/hive_map_rx.dart';
*/

export 'src/ce/hive_list.dart';
export 'src/ce/hive_list_rx.dart';
export 'src/ce/hive_map.dart';
export 'src/ce/hive_map_rx.dart';

class HiveCollection {
  static List<String> registeredAdapterIds = [];
  static Map<String, dynamic Function(String)> registeredKeyAdapters = {};

  static Future<void> ensureInitialized() async {
    // dev-v4 initialization
    // var dir = await getApplicationDocumentsDirectory();
    // Hive.defaultDirectory = dir.path;

    // hive-ce initialization
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  static void registerAdapter<T>(T Function(dynamic) fromJson, Map<String, dynamic> Function(T) toJson) {
    // dev-4 adapter registration
    // final adapterId = T.toString();
    // if (registeredAdapterIds.contains(adapterId)) {
    //   throw Exception(
    //       'Adapter for $adapterId type is already registered. If you want to register an adapter for the type with the same name, please refactor the type name.');
    // }
    // registeredAdapterIds.add(adapterId);
    // Hive.registerAdapter(adapterId, fromJson);
    // print('Registered adapter for $adapterId type');

    // hive-ce adapter registration
    final adapterId = T.toString();
    if (registeredAdapterIds.contains(adapterId)) {
      throw Exception(
          'Adapter for $adapterId type is already registered. If you want to register an adapter for the type with the same name, please refactor the type name.');
    }
    registeredAdapterIds.add(adapterId);
    final adapter = HiveCollectionAdapter.create<T>(fromJson, toJson);
    Hive.registerAdapter(adapter);

    print('[Hive] Registered adapter for $adapterId type');
  }

  static void registerKeyAdapter<T>(T Function(String) fromString) {
    final keyId = T.toString();
    if (registeredKeyAdapters.containsKey(keyId)) {
      throw Exception('Key adapter for $keyId type is already registered.');
    }
    registeredKeyAdapters[keyId] = fromString;
    print('[Hive] Registered key adapter for $keyId type');
  }

  static dynamic Function(String) getKeyAdapter<T>() {
    final adapterId = T.toString();
    if (!registeredKeyAdapters.containsKey(adapterId)) {
      throw Exception('Key adapter for $adapterId type is not registered.');
    }
    return registeredKeyAdapters[adapterId]!;
  }

  HiveCollection._();
}

enum HiveEventType { added, updated, removed }
