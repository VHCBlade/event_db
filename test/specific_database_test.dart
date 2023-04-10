import 'package:event_db/event_db.dart';
import 'package:flutter_test/flutter_test.dart';

import 'models.dart';

Map<Type, ModelConstructor> get constructors => {
      ExampleModel: ExampleModel.new,
      ExampleCompoundModel: ExampleCompoundModel.new,
    };

void main() {
  group("Specific Database", () {
    test("Save And Find", saveAndFindTest);
    test("Delete", deleteTest);
    test("Find All Models Of Type", findAllModelsOfType);
  });
}

void findAllModelsOfType() async {
  final repository = FakeDatabaseRepository(constructors: constructors);
  final database = SpecificDatabase(repository, "Stab");

  await database.saveModel(ExampleModel()..dateTime = DateTime(1998));
  repository.saveModel("Stab", ExampleModel()..dateTime = DateTime(1999));
  repository.saveModel(
      "Stab",
      ExampleCompoundModel()
        ..model = (ExampleModel()..dateTime = DateTime(2000)));
  repository.saveModel(
      "Stab",
      ExampleCompoundModel()
        ..model = (ExampleModel()..dateTime = DateTime(2001)));

  expect(
      (await database.findAllModelsOfType(ExampleModel.new))
          .map((e) => e.dateTime)
          .toSet(),
      {DateTime(1998), DateTime(1999)});
  expect(
      (await database.findAllModelsOfType(ExampleCompoundModel.new))
          .map((e) => e.model.dateTime)
          .toSet(),
      {DateTime(2000), DateTime(2001)});
}

void saveAndFindTest() async {
  final repository = FakeDatabaseRepository(constructors: constructors);
  final database = SpecificDatabase(repository, "Incredible");

  final model = await database.saveModel(ExampleModel()
    ..myEnum = ExampleEnum.yes
    ..dateTime = DateTime(1989));

  expect(model.id, startsWith(ExampleModel().prefixTypeForId("")));
  expect((await database.findModel<ExampleModel>(model.id!))!.dateTime,
      DateTime(1989));
  expect(repository.findModel<ExampleModel>("Incredible", model.id!)!.myEnum,
      ExampleEnum.yes);
}

void deleteTest() async {
  final repository = FakeDatabaseRepository(constructors: constructors);
  final database = SpecificDatabase(repository, "Playful");
  final database2 = SpecificDatabase(repository, "Cool");

  final model = repository.saveModel(
      "Playful", ExampleModel()..dateTime = DateTime(1998));

  await database2.deleteModel(model);

  expect(repository.findModel<ExampleModel>("Playful", model.id!)!.dateTime,
      DateTime(1998));

  await database.deleteModel(model);
  expect(repository.findModel<ExampleModel>("Playful", model.id!), null);
}
