import 'package:event_db/event_db.dart';
import 'package:test/test.dart';

import 'models.dart';

void main() {
  group('JsonStringModel', () {
    test('to and from json string', () {
      final model = ExampleModel();
      final model2 = ExampleModel();

      model
        ..id = '20'
        ..object = 'cool';

      model2.loadFromJsonString(model.toJsonString());

      expect(model2.object, model.object);
      expect(model2.id, model.id);
    });
  });
  group('JsonMap', () {
    test('Read', readTest);
  });
}

void readTest() {
  final example = ExampleModel();
  final compound = ExampleCompoundModel();

  example
    ..dateTime = DateTime(1990)
    ..myEnum = ExampleEnum.yes
    ..object = 'Cool';

  compound
    ..list = [ExampleModel()..dateTime = DateTime(2000)]
    ..map = {'cool': ExampleModel()..object = 'Amazing'}
    ..model = (ExampleModel()..myEnum = ExampleEnum.no);

  expect(
    example.toMap().read<int>('dateTime'),
    DateTime(1990).microsecondsSinceEpoch,
  );
  expect(example.toMap().read<String>('enum'), ExampleEnum.yes.name);
  expect(example.toMap().read<String>('object'), 'Cool');
  expect(example.toMap().read<int>('random'), null);

  expect(
    compound.toMap().read<int>('list.0.dateTime'),
    DateTime(2000).microsecondsSinceEpoch,
  );
  expect(compound.toMap().read<String>('list.0.enum'), null);
  expect(compound.toMap().read<int>('list.1.dateTime'), null);

  expect(compound.toMap().read<String>('map.cool.object'), 'Amazing');
  expect(compound.toMap().read<String>('map.cool.enum'), null);
  expect(compound.toMap().read<String>('map.amazing.object'), null);

  expect(compound.toMap().read<String>('model.enum'), 'no');
  expect(compound.toMap().read<String>('model.type'), 'example');
}
