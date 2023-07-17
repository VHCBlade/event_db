import 'package:event_bloc_tester/event_bloc_tester.dart';
import 'package:event_db/event_db.dart';
import 'package:event_db/src/validator/list.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../models.dart';

void main() {
  group('ListSizeValidator', requiredTest);
}

void requiredTest() {
  SerializableListTester<GenericModel>(
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
