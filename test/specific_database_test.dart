import 'package:event_db/event_db.dart';
import 'package:flutter_test/flutter_test.dart';

import 'models.dart';

Map<Type, ModelConstructor> get constructors => {
      ExampleModel: ExampleModel.new,
      ExampleCompoundModel: ExampleCompoundModel.new,
    };

void main() {
  group('Specific Database', () {
    test('Save And Find', saveAndFindTest);
    test('Delete', deleteTest);
    test('Find All Models Of Type', findAllModelsOfType);
    test('Find Models', findModelsTest);
    test('Save Models', saveModelsTest);
    test('Search By Model And Fields', searchByModelAndFields);
    test('Contains Rows', containsRows);
  });
}

Future<void> containsRows() async {
  final repository = FakeDatabaseRepository(constructors: constructors);
  final database = SpecificDatabase(repository, 'Playful');

  expect(await database.containsRows(ExampleModel.new), false);
  expect(await database.containsRows(ExampleCompoundModel.new), false);

  final model = repository.saveModel(
    'Playful',
    ExampleModel()..dateTime = DateTime(1998),
  );

  expect(await database.containsRows(ExampleModel.new), true);
  expect(await database.containsRows(ExampleCompoundModel.new), false);

  final compounModel = repository.saveModel(
    'Playful',
    ExampleCompoundModel()..model = ExampleModel(),
  );

  expect(await database.containsRows(ExampleModel.new), true);
  expect(await database.containsRows(ExampleCompoundModel.new), true);

  await database.deleteModel(model);

  expect(await database.containsRows(ExampleModel.new), false);
  expect(await database.containsRows(ExampleCompoundModel.new), true);

  await database.deleteModel(compounModel);

  expect(await database.containsRows(ExampleModel.new), false);
  expect(await database.containsRows(ExampleCompoundModel.new), false);
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
  final database = SpecificDatabase(repository, 'Stab');

  final model = ExampleModel()
    ..myEnum = ExampleEnum.no
    ..dateTime = DateTime(1998);

  expect(
    (await database.searchByModelAndFields(
      ExampleModel.new,
      model,
      ['dateTime'],
    ))
        .map((e) => e.idSuffix)
        .toSet(),
    {'1', '2'},
  );
  expect(
    (await database.searchByModelAndFields(
      ExampleModel.new,
      model,
      ['dateTime', 'enum'],
    ))
        .map((e) => e.idSuffix)
        .toSet(),
    {'1'},
  );
  expect(
    (await database.searchByModelAndFields(
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
    (await database.searchByModelAndFields(
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
    (await database.searchByModelAndFields(
      ExampleModel.new,
      model,
      ['enum'],
    ))
        .map((e) => e.idSuffix)
        .toSet(),
    {'4'},
  );
}

Future<void> saveModelsTest() async {
  final repository = FakeDatabaseRepository(constructors: constructors);
  final database = SpecificDatabase(repository, 'Stab')
    ..saveModels(
      [
        ExampleModel()
          ..dateTime = DateTime(1998)
          ..id = '1',
        ExampleModel()
          ..dateTime = DateTime(1999)
          ..id = '2',
        ExampleModel()
          ..dateTime = DateTime(2000)
          ..id = '3',
        ExampleModel()
          ..dateTime = DateTime(2001)
          ..id = '4',
      ],
    );

  expect(
    (await database.findModels<ExampleModel>([]))
        .map((e) => e.dateTime)
        .toSet(),
    const <DateTime>{},
  );
  expect(
    (await database.findModels<ExampleModel>(['none']))
        .map((e) => e.dateTime)
        .toSet(),
    const <DateTime>{},
  );
  expect(
    (await database.findModels<ExampleModel>(['1', '2']))
        .map((e) => e.dateTime)
        .toSet(),
    {DateTime(1998), DateTime(1999)},
  );
  expect(
    (await database.findModels<ExampleModel>(['3', '4']))
        .map((e) => e.dateTime)
        .toSet(),
    {DateTime(2000), DateTime(2001)},
  );
  expect(
    (await database.findModels<ExampleModel>(['1', '2', '3', '4']))
        .map((e) => e.dateTime)
        .toSet(),
    {DateTime(1998), DateTime(1999), DateTime(2000), DateTime(2001)},
  );
}

Future<void> findModelsTest() async {
  final repository = FakeDatabaseRepository(constructors: constructors);
  final database = SpecificDatabase(repository, 'Stab')
    ..saveModel(
      ExampleModel()
        ..dateTime = DateTime(1998)
        ..id = '1',
    )
    ..saveModel(
      ExampleModel()
        ..dateTime = DateTime(1999)
        ..id = '2',
    )
    ..saveModel(
      ExampleModel()
        ..dateTime = DateTime(2000)
        ..id = '3',
    )
    ..saveModel(
      ExampleModel()
        ..dateTime = DateTime(2001)
        ..id = '4',
    );

  expect(
    (await database.findModels<ExampleModel>([]))
        .map((e) => e.dateTime)
        .toSet(),
    const <DateTime>{},
  );
  expect(
    (await database.findModels<ExampleModel>(['none']))
        .map((e) => e.dateTime)
        .toSet(),
    const <DateTime>{},
  );
  expect(
    (await database.findModels<ExampleModel>(['1', '2']))
        .map((e) => e.dateTime)
        .toSet(),
    {DateTime(1998), DateTime(1999)},
  );
  expect(
    (await database.findModels<ExampleModel>(['3', '4']))
        .map((e) => e.dateTime)
        .toSet(),
    {DateTime(2000), DateTime(2001)},
  );
  expect(
    (await database.findModels<ExampleModel>(['1', '2', '3', '4']))
        .map((e) => e.dateTime)
        .toSet(),
    {DateTime(1998), DateTime(1999), DateTime(2000), DateTime(2001)},
  );
}

Future<void> findAllModelsOfType() async {
  final repository = FakeDatabaseRepository(constructors: constructors);
  final database = SpecificDatabase(repository, 'Stab');

  await database.saveModel(ExampleModel()..dateTime = DateTime(1998));
  repository
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
    (await database.findAllModelsOfType(ExampleModel.new))
        .map((e) => e.dateTime)
        .toSet(),
    {DateTime(1998), DateTime(1999)},
  );
  expect(
    (await database.findAllModelsOfType(ExampleCompoundModel.new))
        .map((e) => e.model.dateTime)
        .toSet(),
    {DateTime(2000), DateTime(2001)},
  );
}

Future<void> saveAndFindTest() async {
  final repository = FakeDatabaseRepository(constructors: constructors);
  final database = SpecificDatabase(repository, 'Incredible');

  final model = await database.saveModel(
    ExampleModel()
      ..myEnum = ExampleEnum.yes
      ..dateTime = DateTime(1989),
  );

  expect(model.id, startsWith(ExampleModel().prefixTypeForId('')));
  expect(
    (await database.findModel<ExampleModel>(model.id!))!.dateTime,
    DateTime(1989),
  );
  expect(
    repository.findModel<ExampleModel>('Incredible', model.id!)!.myEnum,
    ExampleEnum.yes,
  );
}

Future<void> deleteTest() async {
  final repository = FakeDatabaseRepository(constructors: constructors);
  final database = SpecificDatabase(repository, 'Playful');
  final database2 = SpecificDatabase(repository, 'Cool');

  final model = repository.saveModel(
    'Playful',
    ExampleModel()..dateTime = DateTime(1998),
  );

  await database2.deleteModel(model);

  expect(
    repository.findModel<ExampleModel>('Playful', model.id!)!.dateTime,
    DateTime(1998),
  );

  await database.deleteModel(model);
  expect(repository.findModel<ExampleModel>('Playful', model.id!), null);
}
