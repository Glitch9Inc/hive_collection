import 'package:hive_collection/hive_collection.dart';

class MyClass {
  MyClass(this.name, this.age);

  final String name;
  final int age;

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
      };

  factory MyClass.fromJson(Map<String, dynamic> json) => MyClass(
        json['name'] as String,
        json['age'] as int,
      );
}

class MyKey {
  MyKey(this.value);

  final MyClass value;

  @override
  String toString() {
    return '${value.name}, ${value.age}';
  }

  factory MyKey.fromString(String string) {
    final parts = string.split(', ');
    return MyKey(MyClass(parts[0], int.parse(parts[1])));
  }
}

void main() async {
  await HiveCollection.ensureInitialized();
  HiveCollection.registerAdapter((json) => MyClass.fromJson(json), (instance) => instance.toJson());
  HiveCollection.registerKeyAdapter((key) => MyKey.fromString(key));

  // HiveMap
  final hiveMap = await HiveMap.create<String, MyClass>('hiveMap');

  await hiveMap.set('key1', MyClass('Dave', 30));
  print('Saved value: ${hiveMap['key1']}');
  print('Contains key1: ${hiveMap.containsKey('key1')}');

  await hiveMap.remove('key1');
  print('Removed key1: ${hiveMap.containsKey('key1')}');

  await hiveMap.dispose();

  // HiveMap with custom key type
  final hiveMapCustomKey = await HiveMap.create<MyKey, MyClass>('hiveMapCustomKey');

  final key = MyKey(MyClass('Key Dave', 30));
  await hiveMapCustomKey.set(key, MyClass('Dave', 30));
  print('Saved value: ${hiveMapCustomKey[key]}');
  print('Contains key: ${hiveMapCustomKey.containsKey(key)}');

  await hiveMapCustomKey.remove(key);
  print('Removed key: ${hiveMapCustomKey.containsKey(key)}');

  await hiveMapCustomKey.dispose();

  // HiveList
  final hiveList = await HiveList.create<String>('hiveList');

  await hiveList.add('Hello Hive!');
  print('Saved value: ${hiveList[0]}');
  print('Length: ${hiveList.length}');
  print('Contains value: ${hiveList.contains('Hello Hive!')}');

  await hiveList.removeAt(0);
  print('Removed value: ${hiveList.contains('Hello Hive!')}');

  await hiveList.dispose();
}
