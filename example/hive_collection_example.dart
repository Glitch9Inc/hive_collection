import 'dart:io';

import 'package:hive/hive.dart';
import 'package:hive_collection/hive_collection.dart';

Future<void> main() async {
  // Hive 4에서는 `Hive.init()`이 없으므로 저장할 디렉토리를 직접 설정해야 함
  final directory = Directory.systemTemp.createTempSync();
  Hive.defaultDirectory = directory.path;

  // Map 생성
  final testMap = HiveMap<String, String>('testBox');

  // 값 저장
  testMap['key1'] = 'Hello Hive!';
  print('Saved value: ${testMap['key1']}');

  // 값 조회
  print('Retrieved value: ${testMap['key1']}');

  // 키 존재 여부 확인
  print('Contains key1: ${testMap.containsKey('key1')}');

  // 값 삭제
  testMap.remove('key1');
  print('Contains key1: ${testMap.containsKey('key1')}');

  // 디렉토리 삭제
  await directory.delete(recursive: true);
}
