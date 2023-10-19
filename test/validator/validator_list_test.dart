import 'package:event_bloc_tester/event_bloc_tester.dart';
import 'package:event_db/event_db.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../models.dart';

void main() {
  group('ListSizeValidator', listSizeTest);
  group('ListSubValidator', listSubTest);
}

void listSubTest() {
  SerializableListTester<BaseModel>(
    testGroupName: 'ListSubValidator',
    mainTestName: 'Assert',
    mode: ListTesterMode.auto,
    testFunction: (value, tester) async {
      final list = ['object', 'enum', 'dateTime'];

      for (final testCase in list) {
        try {
          tester.addTestValue(testCase);
          ListSubValidator('list', validator: RequiredValidator(testCase))
              .assertValidate(value.toMap());
          tester.addTestValue('Passed');
        } on ValidationException catch (e) {
          tester.addTestValue(e.message);
        }
      }
    },
    testMap: listSubTestCases,
  ).runTests();
}

void listSizeTest() {
  SerializableListTester<BaseModel>(
    testGroupName: 'ListSizeValidator',
    mainTestName: 'Assert',
    mode: ListTesterMode.auto,
    testFunction: (value, tester) async {
      final list = [
        const Tuple2(0, null),
        const Tuple2(0, 20),
        const Tuple2(0, 5),
        const Tuple2(1, 5),
        const Tuple2(2, 5),
        const Tuple2(3, 10),
        const Tuple2(5, 12),
        const Tuple2(6, 10),
      ];

      for (final testCase in list) {
        try {
          tester.addTestValue('$testCase');
          ListSizeValidator('list', min: testCase.item1, max: testCase.item2)
              .assertValidate(value.toMap());
          tester.addTestValue('Passed');
        } on ValidationException catch (e) {
          tester.addTestValue(e.message);
        }
      }
    },
    testMap: listTestCases,
  ).runTests();
}

final listTestCases = {
  'Empty': () => ExampleCompoundModel()
    ..model = ExampleModel()
    ..list = [],
  'One': () => ExampleCompoundModel()
    ..model = ExampleModel()
    ..list = [ExampleModel()],
  'Two': () => ExampleCompoundModel()
    ..model = ExampleModel()
    ..list = [
      ExampleModel(),
      ExampleModel(),
    ],
  'Five': () => ExampleCompoundModel()
    ..model = ExampleModel()
    ..list = List.generate(5, (index) => ExampleModel()),
  'Ten': () => ExampleCompoundModel()
    ..model = ExampleModel()
    ..list = List.generate(10, (index) => ExampleModel()),
};

final listSubTestCases = {
  'Empty': () => ExampleCompoundModel()
    ..model = ExampleModel()
    ..list = [],
  'One - Enum': () => ExampleCompoundModel()
    ..model = ExampleModel()
    ..list = [ExampleModel()..myEnum = ExampleEnum.no],
  'One - DateTime': () => ExampleCompoundModel()
    ..model = ExampleModel()
    ..list = [ExampleModel()..dateTime = DateTime(1990)],
  'Two - Object': () => ExampleCompoundModel()
    ..model = ExampleModel()
    ..list = [
      ExampleModel()
        ..dateTime = DateTime(1990)
        ..object = 'Great',
      ExampleModel()..object = 'Amazing',
    ],
  'Two - Enum': () => ExampleCompoundModel()
    ..model = ExampleModel()
    ..list = [
      ExampleModel()
        ..dateTime = DateTime(1990)
        ..object = 'Great'
        ..myEnum = ExampleEnum.yes,
      ExampleModel()..myEnum = ExampleEnum.no,
    ],
};
