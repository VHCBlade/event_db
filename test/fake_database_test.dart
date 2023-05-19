import 'package:event_db/src/fake.dart';
import 'package:flutter_test/flutter_test.dart';

import 'models.dart';

Map<Type, ModelConstructor> get constructors => {
      ExampleModel: ExampleModel.new,
      ExampleCompoundModel: ExampleCompoundModel.new,
    };

void main() {
  group('Fake Database', () {
    test('Save And Find', saveAndFindTest);
    test('Delete', deleteTest);
    test('Find All Models Of Type', findAllModelsOfType);
  });
}

void findAllModelsOfType() {
  final repository = FakeDatabaseRepository(constructors: constructors)
    ..saveModel('Stab', ExampleModel()..dateTime = DateTime(1998))
    ..saveModel('Stab', ExampleModel()..dateTime = DateTime(1999))
    ..saveModel(
      'Stab',
      ExampleCompoundModel()
        ..model = (ExampleModel()..dateTime = DateTime(2000)),
    )
    ..saveModel(
      'Stab',
      ExampleCompoundModel()
        ..model = (ExampleModel()..dateTime = DateTime(2001)),
    );

  expect(
    repository
        .findAllModelsOfType('Stab', ExampleModel.new)
        .map((e) => e.dateTime)
        .toSet(),
    {DateTime(1998), DateTime(1999)},
  );
  expect(
    repository
        .findAllModelsOfType('Stab', ExampleCompoundModel.new)
        .map((e) => e.model.dateTime)
        .toSet(),
    {DateTime(2000), DateTime(2001)},
  );
}

void deleteTest() {
  final repository = FakeDatabaseRepository(constructors: constructors);

  final model = repository.saveModel(
    'Playful',
    ExampleModel()..dateTime = DateTime(1998),
  );

  repository.deleteModel('Cool', model);

  expect(
    repository.findModel<ExampleModel>('Playful', model.id!)!.dateTime,
    DateTime(1998),
  );

  repository.deleteModel('Playful', model);
  expect(repository.findModel<ExampleModel>('Playful', model.id!), null);
}

void saveAndFindTest() {
  final repository = FakeDatabaseRepository(constructors: constructors);

  final model = repository.saveModel(
    'Incredible',
    ExampleModel()
      ..myEnum = ExampleEnum.yes
      ..dateTime = DateTime(1989),
  );

  expect(model.id, startsWith(ExampleModel().prefixTypeForId('')));
  expect(
    repository.findModel<ExampleModel>('Incredible', model.id!)!.dateTime,
    DateTime(1989),
  );
  expect(
    repository.findModel<ExampleModel>('Incredible', model.id!)!.myEnum,
    ExampleEnum.yes,
  );

  model
    ..myEnum = ExampleEnum.yes
    ..dateTime = DateTime(2000);

  expect(
    repository.findModel<ExampleModel>('Incredible', model.id!)!.dateTime,
    DateTime(1989),
  );
  expect(
    repository.findModel<ExampleModel>('Incredible', model.id!)!.myEnum,
    ExampleEnum.yes,
  );
  expect(repository.findModel<ExampleModel>('Wow', model.id!), null);
  expect(repository.findModel<ExampleModel>('Stupendous', model.id!), null);
}
