import 'package:event_bloc_tester/event_bloc_tester.dart';
import 'package:event_db/event_db.dart';
import 'package:test/test.dart';

import 'models.dart';

void main() {
  group('RequiredValidator', requiredTest);
  group('ValidatorCollection', validatorCollectionTest);
  group('NumRangeValidator', numRangeTest);
  group('PastDateTimeValidator', pastDateTimeTest);
}

void validatorCollectionTest() {
  SerializableListTester<GenericModel>(
    testGroupName: 'ValidatorCollection',
    mainTestName: 'Assert',
    mode: ListTesterMode.auto,
    testFunction: (value, tester) async {
      final list = [
        ['type', 'object', 'enum', 'model'],
        ['map', 'map.amazing', 'map.amazing.dateTime'],
        ['map.amazing.enum'],
        ['list.0.type', 'list.0'],
        ['list.0.dateTime', 'list.1.type', 'list'],
        ['name', 'ordinal', 'id']
      ];

      for (final testCase in list) {
        try {
          tester.addTestValue(testCase);
          ValidatorCollection(
            testCase.map(RequiredValidator.new).toList(),
          ).assertValidate(value.toMap());
          tester.addTestValue('Passed');
        } on ValidationCollectionException catch (e) {
          tester.addTestValue(e.exceptions.map((e) => e.message).toList());
        }
      }
    },
    testMap: testCases,
  ).runTests();
}

void numRangeTest() {
  test('Constructor Assertion', () {
    expect(
      const NumRangeValidator('int', min: -7, max: -7),
      isA<NumRangeValidator>(),
    );
    expect(
      () => NumRangeValidator('int', min: -7, max: -8),
      throwsA(isA<AssertionError>()),
    );
  });
  SerializableListTester<List<NumberModel>>(
    testGroupName: 'NumRangeValidator',
    mainTestName: 'Assert',
    mode: ListTesterMode.auto,
    testFunction: (value, tester) async {
      for (final testCase in value) {
        tester.addTestValue('${testCase.intVal}');
        try {
          const NumRangeValidator('int', min: 7, max: 17)
              .assertValidate(testCase.toMap());
          tester.addTestValue('Passed');
        } on ValidationException catch (e) {
          tester.addTestValue(e.message);
        }
        try {
          const NumRangeValidator('int', min: -7, max: 8)
              .assertValidate(testCase.toMap());
          tester.addTestValue('Passed');
        } on ValidationException catch (e) {
          tester.addTestValue(e.message);
        }
        tester.addTestValue('${testCase.doubleVal}');
        try {
          const NumRangeValidator('double', min: 7.25, max: 17.25)
              .assertValidate(testCase.toMap());
          tester.addTestValue('Passed');
        } on ValidationException catch (e) {
          tester.addTestValue(e.message);
        }
        try {
          const NumRangeValidator('double', min: -7.25, max: 7.24)
              .assertValidate(testCase.toMap());
          tester.addTestValue('Passed');
        } on ValidationException catch (e) {
          tester.addTestValue(e.message);
        }
      }
    },
    testMap: numTestCases,
  ).runTests();
}

void requiredTest() {
  SerializableListTester<GenericModel>(
    testGroupName: 'RequiredValidator',
    mainTestName: 'Assert',
    mode: ListTesterMode.auto,
    testFunction: (value, tester) async {
      final list = [
        'type',
        'object',
        'enum',
        'model',
        'map',
        'map.amazing',
        'map.amazing.dateTime',
        'map.amazing.enum',
        'list.0.type',
        'list.0.dateTime',
        'list.1.type',
        'list',
        'name',
        'ordinal',
        'id'
      ];

      for (final testCase in list) {
        try {
          tester.addTestValue(testCase);
          RequiredValidator(testCase).assertValidate(value.toMap());
          tester.addTestValue('Passed');
        } on ValidationException catch (e) {
          tester.addTestValue(e.message);
        }
      }
    },
    testMap: testCases,
  ).runTests();
}

void pastDateTimeTest() {
  SerializableListTester<DateTime?>(
    testGroupName: 'PastDateTimeValidator',
    mainTestName: 'Assert',
    mode: ListTesterMode.auto,
    testFunction: (value, tester) async {
      try {
        const PastDateTimeValidator('DateTime').assertValidate(
          {'DateTime': value?.microsecondsSinceEpoch},
        );
        tester.addTestValue('Passed');
      } on ValidationException catch (e) {
        tester.addTestValue(e.message);
      }
    },
    testMap: dateTimeTestCases,
  ).runTests();
}

final testCases = {
  'Example': () => ExampleModel()
    ..object = 'Amazing'
    ..myEnum = ExampleEnum.no,
  'Compound': () => ExampleCompoundModel()
    ..model = (ExampleModel()..dateTime = DateTime(1990))
    ..map = {'amazing': ExampleModel()}
    ..list = [ExampleModel()],
  'Reorderable': () => ExampleReorderableModel()
    ..name = 'Great'
    ..ordinal = 1,
};

final numTestCases = {
  'Null': () => [NumberModel()],
  'Int': () => [
        NumberModel()..intVal = 7,
        NumberModel()..intVal = 17,
        NumberModel()..intVal = -7,
      ],
  'Double': () => [
        NumberModel()..doubleVal = 7.25,
        NumberModel()..doubleVal = 17.25,
        NumberModel()..doubleVal = -7.25,
      ],
  'Both': () => [
        NumberModel()
          ..intVal = 17
          ..doubleVal = 7.25,
        NumberModel()
          ..doubleVal = -7
          ..doubleVal = 17.25,
        NumberModel()
          ..intVal = 7
          ..doubleVal = -7.25,
      ]
};

final dateTimeTestCases = {
  'Null': () => null,
  'Far Past': () => DateTime.now().subtract(const Duration(days: 365)),
  'Near Past': () => DateTime.now().subtract(const Duration(seconds: 60)),
  'Near Future': () => DateTime.now().add(const Duration(seconds: 60)),
  'Far Future': () => DateTime.now().add(const Duration(days: 365)),
};
