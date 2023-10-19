import 'package:event_bloc_tester/event_bloc_tester.dart';
import 'package:event_db/event_db.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import 'models.dart';

void main() {
  group('GenericModel', () {
    group('To and From Map', () {
      test('Simple', () {
        final model = ExampleModel();
        final model2 = ExampleModel();

        model
          ..id = '20'
          ..object = 'cool';

        model2.loadFromMap(model.toMap());

        expect(model2.object, model.object);
        expect(model2.id, model.id);
      });
      test('Enum', () {
        final model = ExampleModel();
        final model2 = ExampleModel();

        model
          ..id = '20'
          ..object = 'cool'
          ..myEnum = ExampleEnum.yes;

        model2.loadFromMap(model.toMap());

        expect(model2.object, model.object);
        expect(model2.id, model.id);
        expect(model2.myEnum, model.myEnum);

        model2.loadFromMap(model.toMap()..['enum'] = 'afslkews');
        expect(model2.myEnum, null);
      });
      test('Date Time', () {
        final model = ExampleModel();
        final model2 = ExampleModel();

        model
          ..id = '20'
          ..object = 'cool'
          ..myEnum = ExampleEnum.yes
          ..dateTime = DateTime(1970, 5);

        model2.loadFromMap(model.toMap());

        expect(model2.object, model.object);
        expect(model2.id, model.id);
        expect(model2.myEnum, model.myEnum);
        expect(model.dateTime, model2.dateTime);
      });
    });
    group('Copy', () {
      test('Basic', () {
        final model = ExampleModel();
        final model2 = ExampleModel();

        model
          ..id = '20'
          ..object = 'cool';

        model2.copy(model);

        expect(model2.object, model.object);
        expect(model2.id, model.id);
      });
      test('Type Mismatch', () {
        final model = ExampleModel();
        final model2 = ExampleCompoundModel();

        model
          ..id = '20'
          ..object = 'cool';

        expect(() => model2.copy(model), throwsA(isA<FormatException>()));
      });
      test('Only Fields', () {
        final model = ExampleModel();
        final model2 = ExampleModel();

        model
          ..id = '20'
          ..object = 'cool';

        model2.copy(model, onlyFields: ['object']);

        expect(model2.object, model.object);
        expect(model2.id, null);
      });
      test('Except Fields', () {
        final model = ExampleModel();
        final model2 = ExampleModel();

        model
          ..id = '20'
          ..object = 'cool';

        model2.copy(model, exceptFields: ['object']);

        expect(model2.id, model.id);
        expect(model2.object, null);
      });
      test('idSuffix', () {
        final model = ExampleModel();

        expect(model.idSuffix, null);
        model.id = 'cool';
        expect(model.idSuffix, 'cool');
        model.idSuffix = 'amazing';
        expect(model.id, 'example::amazing');
        expect(model.idSuffix, 'amazing');
        model.idSuffix = 'amazing::incredible';
        expect(model.id, 'example::amazing::incredible');
        expect(model.idSuffix, 'incredible');
      });
    });

    group('Id Suffix', () {
      test('Generate', () {
        final model = ExampleModel();
        final model2 = ExampleModel();

        expect(model.autoGenId, startsWith(ExampleModel().type));
        expect(model2.autoGenId, startsWith(ExampleModel().type));

        expect(model.autoGenId, model.id);
        expect(model2.autoGenId, model2.id);
      });
      test('Already Existing', () {
        final model = ExampleModel();
        final model2 = ExampleModel();

        model.id = '20';
        model2.id = 'great';

        expect(model.autoGenId, '20');
        expect(model2.autoGenId, 'great');
      });
    });

    group('hasSameFields', hasSameFieldsTest);
    group('getterSetter Assertion', getterSetterAssertionTest);
  });
}

class _FakeIdModel extends GenericModel {
  @override
  Map<String, Tuple2<Getter<dynamic>, Setter<dynamic>>> getGetterSetterMap() =>
      {GenericModel.ID: Tuple2(() => 'cool', (val) => '')};

  @override
  String get type => 'Cool';
}

class _FakeTypeModel extends GenericModel {
  @override
  Map<String, Tuple2<Getter<dynamic>, Setter<dynamic>>> getGetterSetterMap() =>
      {GenericModel.TYPE: Tuple2(() => 'cool', (val) => '')};

  @override
  String get type => 'Cool';
}

void getterSetterAssertionTest() {
  test('Type', () {
    expect(() => _FakeIdModel()..toMap(), throwsA(isA<AssertionError>()));
  });
  test('ID', () {
    expect(() => _FakeTypeModel()..toMap(), throwsA(isA<AssertionError>()));
  });
}

void hasSameFieldsTest() {
  SerializableListTester<Tuple2<ExampleModel, ExampleModel>>(
    testGroupName: 'GenericModel',
    mainTestName: 'hasSameFields',
    mode: ListTesterMode.auto,
    testFunction: (value, tester) async {
      tester
        ..addTestValue('All Fields')
        ..addTestValue(value.item1.hasSameFields(model: value.item2))
        ..addTestValue(value.item2.hasSameFields(model: value.item1))
        ..addTestValue('All But Id')
        ..addTestValue(
          value.item1.hasSameFields(
            model: value.item2,
            exceptFields: [GenericModel.ID],
          ),
        )
        ..addTestValue(
          value.item2.hasSameFields(
            model: value.item1,
            exceptFields: [GenericModel.ID],
          ),
        )
        ..addTestValue('Just ID')
        ..addTestValue(
          value.item1.hasSameFields(
            model: value.item2,
            onlyFields: [GenericModel.ID],
          ),
        )
        ..addTestValue(
          value.item2.hasSameFields(
            model: value.item1,
            onlyFields: [GenericModel.ID],
          ),
        )
        ..addTestValue('Mixed')
        ..addTestValue(
          value.item1.hasSameFields(
            model: value.item2,
            onlyFields: [GenericModel.ID, 'dateTime'],
          ),
        )
        ..addTestValue(
          value.item1.hasSameFields(
            model: value.item2,
            exceptFields: [GenericModel.ID, 'dateTime'],
          ),
        )
        ..addTestValue(
          value.item2.hasSameFields(
            model: value.item1,
            onlyFields: ['enum', 'object'],
          ),
        )
        ..addTestValue(
          value.item2.hasSameFields(
            model: value.item1,
            exceptFields: ['enum', 'object'],
          ),
        );
    },
    testMap: comparisonTestCases,
  ).runTests();
}

Map<String, Tuple2<ExampleModel, ExampleModel> Function()> comparisonTestCases =
    {
  'Identity': () {
    final model = ExampleModel()
      ..id = 'a'
      ..myEnum = ExampleEnum.yes
      ..dateTime = DateTime.now();
    return Tuple2(model, ExampleModel()..copy(model));
  },
  'Different Id': () {
    final model = ExampleModel()
      ..id = 'b'
      ..myEnum = ExampleEnum.no
      ..dateTime = DateTime(1990, 20)
      ..object = 'Great';
    return Tuple2(
      model,
      ExampleModel()
        ..copy(model)
        ..id = 'cool',
    );
  },
  'Same Id': () {
    final model = ExampleModel()
      ..id = 'b'
      ..myEnum = ExampleEnum.no
      ..dateTime = DateTime(1990, 20)
      ..object = 'Great';
    return Tuple2(
      model,
      ExampleModel()
        ..copy(model)
        ..myEnum = ExampleEnum.yes
        ..dateTime = DateTime.now()
        ..object = null,
    );
  },
  'Some Same Values': () {
    final model = ExampleModel()
      ..id = 'b'
      ..myEnum = ExampleEnum.no
      ..dateTime = DateTime(1990, 20)
      ..object = 'Great';
    return Tuple2(
      model,
      ExampleModel()
        ..copy(model)
        ..id = 'Amazing'
        ..dateTime = DateTime.now(),
    );
  },
};
