import 'package:event_db/src/model.dart';
import 'package:event_db/src/repository.dart';

// TODO: BP-32
class GenericModelMap<T extends GenericModel> {
  final Map<String, T> map = {};
  final T Function() supplier;
  final DatabaseRepository Function() repository;
  final String? defaultDatabaseName;

  /// Maintains a [map] for the [T] models with their [id] as their key.
  ///
  /// [supplier] generates a new instance of [T]
  ///
  /// [repository] gives this the instance of the [DatabaseRepository] to be used in the automatic loading functions of this class.
  ///
  /// [defaultDatabaseName] is the database the [repository] will use. This can be overridden in all the loading functions of this class.
  GenericModelMap({
    required this.repository,
    required this.supplier,
    this.defaultDatabaseName,
  });

  /// Creates the [SpecificDatabase] using the [defaultDatabaseName] passed in the constructor.
  ///
  /// if [databaseName] is provided, it will use that rather than [defaultDatabaseName]
  SpecificDatabase specificDatabase([String? databaseName]) {
    assert(databaseName != null || defaultDatabaseName != null);
    return SpecificDatabase(repository(), databaseName ?? defaultDatabaseName!);
  }

  void addLoadedModels(Iterable<T> models) =>
      map.addAll({for (final model in models) model.id!: model});

  void removeLoadedModels(Iterable<T> models) {
    final set = models.map((e) => e.id).toSet();
    map.removeWhere((key, value) => set.contains(key));
  }

  Future<Iterable<T>> loadAll({String? databaseName}) async {
    final database = specificDatabase(databaseName);
    final models = await database.findAllModelsOfType(supplier);
    addLoadedModels(models);
    return models;
  }

  Future<Iterable<T>> loadModelIds(Iterable<String> ids,
      {String? databaseName}) async {
    final database = specificDatabase(databaseName);

    // TODO BP-17 Combine loading of values into one.
    final loadedModels =
        (await Future.wait(ids.map((e) async => database.findModel<T>(e))))
            .where((element) => element != null)
            .map((e) => e!);
    addLoadedModels(loadedModels);
    return loadedModels;
  }

  Future<T> addModel(T model, {String? databaseName}) async {
    final database = specificDatabase(databaseName);

    final newModel = await database.saveModel<T>(model);
    addLoadedModels([newModel]);

    return newModel;
  }

  Future<bool> deleteModel(T model, {String? databaseName}) async {
    final database = specificDatabase(databaseName);

    final successful = await database.deleteModel<T>(model);
    if (successful) {
      removeLoadedModels([model]);
    }
    return successful;
  }

  Future<T> updateModel(T model, {String? databaseName}) async {
    final database = specificDatabase(databaseName);

    final newModel = await database.saveModel<T>(model);
    addLoadedModels([newModel]);
    return newModel;
  }
}
