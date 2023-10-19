import 'package:event_db/event_db.dart';
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
    test('Find Models', findModelsTest);
    test('Missing Constructor', missingConstructorTest);
    test('searchByModelAndFields', searchByModelAndFields);
  });
}

Future<void> searchByModelAndFields() async {
  final repository = FakeDatabaseRepository(constructors: constructors)
    ..saveModel(
      'Stab',
      ExampleModel()
        ..dateTime = DateTime(1998)
        ..myEnum = ExampleEnum.no
        ..idSuffix = '1',
    )
    ..saveModel(
      'Stab',
      ExampleModel()
        ..dateTime = DateTime(1998)
        ..object = 'a'
        ..myEnum = ExampleEnum.yes
        ..idSuffix = '2',
    )
    ..saveModel(
      'Stab',
      ExampleModel()
        ..dateTime = DateTime(2000)
        ..myEnum = ExampleEnum.no
        ..idSuffix = '3',
    )
    ..saveModel(
      'Stab',
      ExampleModel()
        ..dateTime = DateTime(2000)
        ..object = 'a'
        ..idSuffix = '4',
    );

  final model = ExampleModel()
    ..myEnum = ExampleEnum.no
    ..dateTime = DateTime(1998);

  expect(
    (await repository.searchByModelAndFields(
      'Stab',
      ExampleModel.new,
      model,
      ['dateTime'],
    ))
        .map((e) => e.idSuffix)
        .toSet(),
    {'1', '2'},
  );
  expect(
    (await repository.searchByModelAndFields(
      'Stab',
      ExampleModel.new,
      model,
      ['dateTime', 'enum'],
    ))
        .map((e) => e.idSuffix)
        .toSet(),
    {'1'},
  );
  expect(
    (await repository.searchByModelAndFields(
      'Stab',
      ExampleModel.new,
      model,
      ['enum'],
    ))
        .map((e) => e.idSuffix)
        .toSet(),
    {'1', '3'},
  );
  model.myEnum = ExampleEnum.yes;
  expect(
    (await repository.searchByModelAndFields(
      'Stab',
      ExampleModel.new,
      model,
      ['enum'],
    ))
        .map((e) => e.idSuffix)
        .toSet(),
    {'2'},
  );
  model.myEnum = null;
  expect(
    (await repository.searchByModelAndFields(
      'Stab',
      ExampleModel.new,
      model,
      ['enum'],
    ))
        .map((e) => e.idSuffix)
        .toSet(),
    {'4'},
  );
}

void missingConstructorTest() {
  final fakeRepository = FakeDatabaseRepository(constructors: {});

  expect(
    () => fakeRepository.saveModel<ExampleModel>(
      'database',
      ExampleModel()..dateTime = DateTime(1999),
    ),
    throwsArgumentError,
  );
}

Future<void> findModelsTest() async {
  final repository = FakeDatabaseRepository(constructors: constructors)
    ..saveModel(
      'Stab',
      ExampleModel()
        ..dateTime = DateTime(1998)
        ..id = '1',
    )
    ..saveModel(
      'Stab',
      ExampleModel()
        ..dateTime = DateTime(1999)
        ..id = '2',
    )
    ..saveModel(
      'Stab',
      ExampleModel()
        ..dateTime = DateTime(2000)
        ..id = '3',
    )
    ..saveModel(
      'Stab',
      ExampleModel()
        ..dateTime = DateTime(2001)
        ..id = '4',
    );

  expect(
    (await repository.findModels<ExampleModel>('Stab', []))
        .map((e) => e.dateTime)
        .toSet(),
    const <DateTime>{},
  );
  expect(
    (await repository.findModels<ExampleModel>('Stab', ['none']))
        .map((e) => e.dateTime)
        .toSet(),
    const <DateTime>{},
  );
  expect(
    (await repository.findModels<ExampleModel>('Stab', ['1', '2']))
        .map((e) => e.dateTime)
        .toSet(),
    {DateTime(1998), DateTime(1999)},
  );
  expect(
    (await repository.findModels<ExampleModel>('Stab', ['3', '4']))
        .map((e) => e.dateTime)
        .toSet(),
    {DateTime(2000), DateTime(2001)},
  );
  expect(
    (await repository.findModels<ExampleModel>('Stab', ['1', '2', '3', '4']))
        .map((e) => e.dateTime)
        .toSet(),
    {DateTime(1998), DateTime(1999), DateTime(2000), DateTime(2001)},
  );
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
