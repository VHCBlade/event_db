import 'dart:math';

import 'package:event_bloc_tester/event_bloc_tester.dart';
import 'package:event_db/event_db.dart';
import 'package:flutter_test/flutter_test.dart';

import 'models.dart';

void main() {
  group("Reorderable", () {
    group("Insert", insertTest);
    group("Move Down", moveDownTest);
    group("Move Up", moveUpTest);
  });
}

Future<GenericModelMap<ExampleReorderableModel>> setupMap(
    Iterable<ExampleReorderableModel> initialModels) async {
  final repository = FakeDatabaseRepository(
      constructors: {ExampleReorderableModel: ExampleReorderableModel.new});

  initialModels
      .forEach((e) => repository.saveModel<ExampleReorderableModel>("Cool", e));

  final map = GenericModelMap(
      repository: () => repository,
      supplier: ExampleReorderableModel.new,
      defaultDatabaseName: "Cool");

  await map.loadAll();

  return map;
}

void moveUpTest() {
  final tester = SerializableListTester<List<ExampleReorderableModel>>(
    testGroupName: "Reorderable",
    mainTestName: "Move Up",
    // mode: ListTesterMode.generateOutput,
    mode: ListTesterMode.testOutput,
    testFunction: (value, tester) async {
      final map = await setupMap(value);
      await map.addModel(map.setOrdinalOfNewEntry(
          ExampleReorderableModel()..name = "Inserted One"));

      map.reorder(map.defaultOrderedList[min(100, map.map.length - 1)], 0);
      tester.addTestValue(map.defaultOrderedList.map((e) => e.name).toList());

      map.reorder(map.defaultOrderedList[min(100, map.map.length - 1)], 3);
      tester.addTestValue(map.defaultOrderedList.map((e) => e.name).toList());

      map.reorder(map.defaultOrderedList[min(5, map.map.length - 1)], 0);
      tester.addTestValue(map.defaultOrderedList.map((e) => e.name).toList());

      map.reorder(map.defaultOrderedList[min(8, map.map.length - 1)], 4);
      tester.addTestValue(map.defaultOrderedList.map((e) => e.name).toList());

      map.reorder(map.defaultOrderedList[min(9, map.map.length - 1)], 7);
      tester.addTestValue(map.defaultOrderedList.map((e) => e.name).toList());
    },
    testMap: commonTestCases,
  );

  tester.runTests();
}

void moveDownTest() {
  final tester = SerializableListTester<List<ExampleReorderableModel>>(
    testGroupName: "Reorderable",
    mainTestName: "Move Down",
    // mode: ListTesterMode.generateOutput,
    mode: ListTesterMode.testOutput,
    testFunction: (value, tester) async {
      final map = await setupMap(value);
      await map.addModel(map.setOrdinalOfNewEntry(
          ExampleReorderableModel()..name = "Inserted One"));

      map.reorder(map.defaultOrderedList[min(0, map.map.length - 1)], 100);
      tester.addTestValue(map.defaultOrderedList.map((e) => e.name).toList());

      map.reorder(map.defaultOrderedList[min(0, map.map.length - 1)], 3);
      tester.addTestValue(map.defaultOrderedList.map((e) => e.name).toList());

      map.reorder(map.defaultOrderedList[min(5, map.map.length - 1)], 8);
      tester.addTestValue(map.defaultOrderedList.map((e) => e.name).toList());

      map.reorder(map.defaultOrderedList[min(2, map.map.length - 1)], 4);
      tester.addTestValue(map.defaultOrderedList.map((e) => e.name).toList());

      map.reorder(map.defaultOrderedList[min(1, map.map.length - 1)], 1000);
      tester.addTestValue(map.defaultOrderedList.map((e) => e.name).toList());
    },
    testMap: commonTestCases,
  );

  tester.runTests();
}

void insertTest() {
  final tester = SerializableListTester<List<ExampleReorderableModel>>(
    testGroupName: "Reorderable",
    mainTestName: "Insert",
    // mode: ListTesterMode.generateOutput,
    mode: ListTesterMode.testOutput,
    testFunction: (value, tester) async {
      final map = await setupMap(value);
      await map.addModel(map.setOrdinalOfNewEntry(
          ExampleReorderableModel()..name = "Inserted One"));
      tester.addTestValue(map.defaultOrderedList.map((e) => e.name).toList());
      await map.addModel(map.setOrdinalOfNewEntry(
          ExampleReorderableModel()..name = "Inserted Two"));
      tester.addTestValue(map.defaultOrderedList.map((e) => e.name).toList());
    },
    testMap: commonTestCases,
  );

  tester.runTests();
}

Map<String, List<ExampleReorderableModel> Function()> get commonTestCases => {
      "Nothing": () => [],
      "One": () => [
            ExampleReorderableModel()
              ..name = "One"
              ..ordinal = 0
          ],
      "Three": () => [
            ExampleReorderableModel()
              ..name = "One"
              ..ordinal = 0,
            ExampleReorderableModel()
              ..name = "Two"
              ..ordinal = 1,
            ExampleReorderableModel()
              ..name = "Three"
              ..ordinal = 2,
          ],
      "Five": () => [
            ExampleReorderableModel()
              ..name = "One"
              ..ordinal = 0,
            ExampleReorderableModel()
              ..name = "Two"
              ..ordinal = 1,
            ExampleReorderableModel()
              ..name = "Three"
              ..ordinal = 2,
            ExampleReorderableModel()
              ..name = "Four"
              ..ordinal = 3,
            ExampleReorderableModel()
              ..name = "Five"
              ..ordinal = 4,
          ],
      "Ten": () => [
            ExampleReorderableModel()
              ..name = "One"
              ..ordinal = 0,
            ExampleReorderableModel()
              ..name = "Two"
              ..ordinal = 1,
            ExampleReorderableModel()
              ..name = "Three"
              ..ordinal = 2,
            ExampleReorderableModel()
              ..name = "Four"
              ..ordinal = 3,
            ExampleReorderableModel()
              ..name = "Five"
              ..ordinal = 4,
            ExampleReorderableModel()
              ..name = "Six"
              ..ordinal = 5,
            ExampleReorderableModel()
              ..name = "Seven"
              ..ordinal = 6,
            ExampleReorderableModel()
              ..name = "Eight"
              ..ordinal = 7,
            ExampleReorderableModel()
              ..name = "Nine"
              ..ordinal = 8,
            ExampleReorderableModel()
              ..name = "Ten"
              ..ordinal = 9,
          ],
      "Eleven": () => [
            ExampleReorderableModel()
              ..name = "One"
              ..ordinal = 0,
            ExampleReorderableModel()
              ..name = "Two"
              ..ordinal = 1,
            ExampleReorderableModel()
              ..name = "Three"
              ..ordinal = 2,
            ExampleReorderableModel()
              ..name = "Four"
              ..ordinal = 3,
            ExampleReorderableModel()
              ..name = "Five"
              ..ordinal = 4,
            ExampleReorderableModel()
              ..name = "Six"
              ..ordinal = 5,
            ExampleReorderableModel()
              ..name = "Seven"
              ..ordinal = 6,
            ExampleReorderableModel()
              ..name = "Eight"
              ..ordinal = 7,
            ExampleReorderableModel()
              ..name = "Nine"
              ..ordinal = 8,
            ExampleReorderableModel()
              ..name = "Ten"
              ..ordinal = 9,
            ExampleReorderableModel()
              ..name = "Eleven"
              ..ordinal = 10,
          ],
      "Twelve": () => [
            ExampleReorderableModel()
              ..name = "One"
              ..ordinal = 0,
            ExampleReorderableModel()
              ..name = "Two"
              ..ordinal = 1,
            ExampleReorderableModel()
              ..name = "Three"
              ..ordinal = 2,
            ExampleReorderableModel()
              ..name = "Four"
              ..ordinal = 3,
            ExampleReorderableModel()
              ..name = "Five"
              ..ordinal = 4,
            ExampleReorderableModel()
              ..name = "Six"
              ..ordinal = 5,
            ExampleReorderableModel()
              ..name = "Seven"
              ..ordinal = 6,
            ExampleReorderableModel()
              ..name = "Eight"
              ..ordinal = 7,
            ExampleReorderableModel()
              ..name = "Nine"
              ..ordinal = 8,
            ExampleReorderableModel()
              ..name = "Ten"
              ..ordinal = 9,
            ExampleReorderableModel()
              ..name = "Eleven"
              ..ordinal = 10,
            ExampleReorderableModel()
              ..name = "Twelve"
              ..ordinal = 11,
          ],
    };
