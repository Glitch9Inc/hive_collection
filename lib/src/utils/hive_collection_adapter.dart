import 'package:hive_ce/hive.dart' hide HiveList, HiveCollection;

class HiveCollectionAdapter<T> extends TypeAdapter<T> {
  static int _typeId = 0;
  static int _getTypeId() => _typeId++;

  @override
  final int typeId;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  HiveCollectionAdapter._(
    this.fromJson,
    this.toJson,
  ) : typeId = _getTypeId();

  static HiveCollectionAdapter<T> create<T>(
    T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic> Function(T) toJson,
  ) =>
      HiveCollectionAdapter<T>._(fromJson, toJson);

  @override
  T read(BinaryReader reader) {
    try {
      final json = reader.readMap();
      return fromJson(json as Map<String, dynamic>);
    } catch (e) {
      print('Failed to read object from Hive: $e');
      rethrow;
    }
  }

  @override
  void write(BinaryWriter writer, T obj) {
    try {
      final json = toJson(obj);
      writer.writeMap(json);
    } catch (e) {
      print('Failed to write object to Hive: $e');
      rethrow;
    }
  }
}
