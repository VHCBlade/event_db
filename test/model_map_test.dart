import 'package:event_db/event_db.dart';
import 'package:test/test.dart';

import 'models.dart';

void main() {
  group('GenericModelMap', () {
    test('No Database Name', () {
      final repository = FakeDatabaseRepository(
        constructors: {ExampleModel: ExampleModel.new},
      );
      final map = GenericModelMap(
        repository: () => repository,
        supplier: ExampleModel.new,
      );
      expect(
        () => map.addModel(ExampleModel()),
        throwsA(isA<AssertionError>()),
      );
    });
    test('AddModel', () async {
      final repository = FakeDatabaseRepository(
        constructors: {ExampleModel: ExampleModel.new},
      );
      final coolMap = GenericModelMap(
        repository: () => repository,
        supplier: ExampleModel.new,
        defaultDatabaseName: 'cool',
      );
      final radMap = GenericModelMap(
        repository: () => repository,
        supplier: ExampleModel.new,
        defaultDatabaseName: 'rad',
      );

      await coolMap.addModel(ExampleModel()..idSuffix = '1');
      await radMap.addModel(ExampleModel()..idSuffix = '2');

      await coolMap.addModel(
        ExampleModel()..idSuffix = '3',
        databaseName: 'rad',
      );
      await radMap.addModel(
        ExampleModel()..idSuffix = '4',
        databaseName: 'cool',
      );

      expect(coolMap.map.keys.toSet(), {'example::1', 'example::3'});
      expect(radMap.map.keys.toSet(), {'example::2', 'example::4'});

      coolMap.map.clear();
      radMap.map.clear();

      await coolMap.loadAll();
      await radMap.loadAll();

      expect(coolMap.map.keys.toSet(), {'example::1', 'example::4'});
      expect(radMap.map.keys.toSet(), {'example::2', 'example::3'});
    });
    test('LoadModelIds', () async {
      final repository = FakeDatabaseRepository(
        constructors: {ExampleModel: ExampleModel.new},
      );
      final coolMap = GenericModelMap(
        repository: () => repository,
        supplier: ExampleModel.new,
        defaultDatabaseName: 'cool',
      );
      final radMap = GenericModelMap(
        repository: () => repository,
        supplier: ExampleModel.new,
        defaultDatabaseName: 'rad',
      );

      await coolMap.addModel(ExampleModel()..idSuffix = '1');
      await radMap.addModel(ExampleModel()..idSuffix = '2');

      await coolMap.addModel(
        ExampleModel()..idSuffix = '3',
        databaseName: 'rad',
      );
      await radMap.addModel(
        ExampleModel()..idSuffix = '4',
        databaseName: 'cool',
      );

      await coolMap.loadModelIds(['example::4']);
      await radMap.loadModelIds(['example::3']);

      expect(coolMap.map.keys.toSet(), {
        'example::1',
        'example::3',
        'example::4',
      });
      expect(radMap.map.keys.toSet(), {
        'example::2',
        'example::3',
        'example::4',
      });
    });
    test('RemoveLoadedModels', () async {
      final repository = FakeDatabaseRepository(
        constructors: {ExampleModel: ExampleModel.new},
      );
      final coolMap = GenericModelMap(
        repository: () => repository,
        supplier: ExampleModel.new,
        defaultDatabaseName: 'cool',
      );
      final radMap = GenericModelMap(
        repository: () => repository,
        supplier: ExampleModel.new,
        defaultDatabaseName: 'rad',
      );

      await coolMap.addModel(ExampleModel()..idSuffix = '1');
      await radMap.addModel(ExampleModel()..idSuffix = '2');

      await coolMap.addModel(
        ExampleModel()..idSuffix = '3',
        databaseName: 'rad',
      );
      await radMap.addModel(
        ExampleModel()..idSuffix = '4',
        databaseName: 'cool',
      );

      coolMap.removeLoadedModels([ExampleModel()..idSuffix = '1']);
      radMap.removeLoadedModels([ExampleModel()..idSuffix = '2']);

      expect(coolMap.map.keys.toSet(), {'example::3'});
      expect(radMap.map.keys.toSet(), {'example::4'});

      await coolMap.loadAll();
      await radMap.loadAll();

      expect(coolMap.map.keys.toSet(), {
        'example::1',
        'example::3',
        'example::4',
      });
      expect(radMap.map.keys.toSet(), {
        'example::2',
        'example::3',
        'example::4',
      });
    });
    test('DeleteModel', () async {
      final repository = FakeDatabaseRepository(
        constructors: {ExampleModel: ExampleModel.new},
      );
      final coolMap = GenericModelMap(
        repository: () => repository,
        supplier: ExampleModel.new,
        defaultDatabaseName: 'cool',
      );
      final radMap = GenericModelMap(
        repository: () => repository,
        supplier: ExampleModel.new,
        defaultDatabaseName: 'rad',
      );

      await coolMap.addModel(ExampleModel()..idSuffix = '1');
      await radMap.addModel(ExampleModel()..idSuffix = '2');

      await coolMap.addModel(ExampleModel()..idSuffix = '3');
      await radMap.addModel(ExampleModel()..idSuffix = '4');

      await coolMap.deleteModel(ExampleModel()..idSuffix = '3');
      await radMap.deleteModel(ExampleModel()..idSuffix = '4');

      await coolMap.loadAll();
      await radMap.loadAll();

      expect(coolMap.map.keys.toSet(), {'example::1'});
      expect(radMap.map.keys.toSet(), {'example::2'});
    });
  });
}
