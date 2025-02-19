<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

## Hive Collection for Dart/Flutter
Hive Collection is a lightweight, easy-to-use wrapper for Hive that allows you to use Hive boxes like List and Map. 
It provides a simple and efficient way to store and retrieve structured data with minimal effort.

## Features
- List-like storage: HiveList<T> allows storing data like a Dart List<T>.
- Map-like storage: HiveMap<K, V> allows storing data like a Dart Map<K, V>.
- Auto serialization support: Works with fromJson and toJson methods.
- Supports primitive and custom object types.
- Handles Hive key conversions for various types (String, int, double, bool, Enum, DateTime).

## Installation
Add hive_collection as a dependency in your pubspec.yaml file:
```yaml
dependencies:
  hive_collection:
    git: https://github.com/Glitch9Inc/hive_collection.git
```
Then run:
```yaml
flutter pub get
```

## Initialization
Before using HiveCollection, ensure Hive is properly initialized and register your adapters:
```dart
import 'package:hive_collection/hive_collection.dart';

void main() async {
  await HiveCollection.ensureInitialized();
  HiveCollection.registerAdapter(
    (json) => MyClass.fromJson(json),
    (myClassInstance) => myClassInstance.toJson(),
  );
}
```

## Usage
Using HiveList<T> (List-like Storage)
```dart
class MyClass {
  final String name;
  final int age;

  MyClass({required this.name, required this.age});

  factory MyClass.fromJson(Map<String, dynamic> json) {
    return MyClass(name: json['name'], age: json['age']);
  }

  Map<String, dynamic> toJson() => {'name': name, 'age': age};
}

void main() async {
  HiveList<MyClass> myList = await HiveList.create<MyClass>('myList');
  
  myList.add(MyClass(name: 'Alice', age: 25));
  myList.add(MyClass(name: 'Bob', age: 30));

  print(myList.toList());
}
```
Using HiveMap<K, V> (Map-like Storage)
```dart
void main() async {
  HiveMap<String, MyClass> myMap = await HiveMap.create<String, MyClass>('myMap');

  myMap['user1'] = MyClass(name: 'Charlie', age: 22);
  myMap['user2'] = MyClass(name: 'David', age: 28);

  print(myMap.toMap());
}
```
## Supported Key Types
HiveMap supports the following key types:

- String
- int
- double
- bool
- Enum
- DateTime
- Custom key types via key adapters

For custom key types, you can register a key adapter:
```dart
HiveCollection.registerKeyAdapter<Uuid>((key) => Uuid.parse(key));
```
 
## Converting Data
Hive requires serialization of custom objects. HiveCollection provides easy registration for fromJson and toJson methods:
```dart
HiveCollection.registerAdapter(
  (json) => MyClass.fromJson(json),
  (obj) => obj.toJson(),
);
```

## Performance Considerations
- Use HiveMap when storing key-value pairs for quick lookups.
- Use HiveList when you need ordered data storage with indexed access.
- Call .dispose() when you're done using a HiveList or HiveMap to free resources.

## License
This package is open-source and available under the MIT License.

## Contributing
Contributions are welcome! Feel free to submit a PR or report an issue.