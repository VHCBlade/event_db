import 'package:event_db/event_db.dart';

/// Represents a map of [GenericModel]s with functions to automatically
/// retrieve and save them in a [DatabaseRepository]
class GenericModelMap<T extends BaseModel> {
  /// Maintains a [map] for the [T] models with their id as their key.
  ///
  /// [supplier] generates a new instance of [T]
  ///
  /// [repository] gives this the instance of the [DatabaseRepository] to be
  /// used in the automatic loading functions of this class.
  ///
  /// [defaultDatabaseName] is the database the [repository] will use. This can
  /// be overridden in all the loading functions of this class.
  GenericModelMap({
    required this.repository,
    required this.supplier,
    this.defaultDatabaseName,
  });

  /// The map of [BaseModel]s with their id as the key
  final Map<String, T> map = {};

  /// Creates a new instance of [T], provided in the constructor
  final ModelConstructor<T> supplier;

  /// Returns the used [DatabaseRepository] for the various functions provided.
  final DatabaseRepository Function() repository;

  /// Used in the various functions if a databaseName is not specified for them.
  final String? defaultDatabaseName;

  /// Creates the [SpecificDatabase] using the [defaultDatabaseName] passed in
  /// the constructor.
  ///
  /// if [databaseName] is provided, it will use that rather than
  /// [defaultDatabaseName]
  SpecificDatabase specificDatabase([String? databaseName]) {
    assert(
      databaseName != null || defaultDatabaseName != null,
      'At least one of defaultDatabaseName and databaseName needs to be '
      'provided',
    );
    return SpecificDatabase(repository(), databaseName ?? defaultDatabaseName!);
  }

  /// Adds the given [models] to the [map] without adding them to the
  /// [repository]. It is assumed that these are already present.
  void addLoadedModels(Iterable<T> models) =>
      map.addAll({for (final model in models) model.id!: model});

  /// Removes the given [models] to the [map] without removing them from the
  /// [repository]. It is assumed that these have already been removed.
  void removeLoadedModels(Iterable<T> models) {
    final set = models.map((e) => e.id).toSet();
    map.removeWhere((key, value) => set.contains(key));
  }

  /// Loads all of the [T] models present in [repository]
  /// for the given database.
  Future<Iterable<T>> loadAll({String? databaseName}) async {
    final database = specificDatabase(databaseName);
    final models = await database.findAllModelsOfType(supplier);
    addLoadedModels(models);
    return models;
  }

  /// Loads all of the [T] models with the given [ids] in [repository]
  /// for the given database.
  Future<Iterable<T>> loadModelIds(
    Iterable<String> ids, {
    String? databaseName,
  }) async {
    final database = specificDatabase(databaseName);

    final loadedModels = await database.findModels<T>(ids);
    addLoadedModels(loadedModels);
    return loadedModels;
  }

  /// Adds the given [model] to the [map] and the given database in [repository]
  Future<T> addModel(T model, {String? databaseName}) async {
    final database = specificDatabase(databaseName);

    final newModel = await database.saveModel<T>(model);
    addLoadedModels([newModel]);

    return newModel;
  }

  /// Deletes the given [model] from the [map] and the given database in
  /// [repository]
  Future<bool> deleteModel(T model, {String? databaseName}) async {
    final database = specificDatabase(databaseName);

    final successful = await database.deleteModel<T>(model);
    if (successful) {
      removeLoadedModels([model]);
    }
    return successful;
  }

  /// Updates the given [model] to the [map] and the given database in
  /// [repository]
  Future<T> updateModel(T model, {String? databaseName}) async {
    final database = specificDatabase(databaseName);

    final newModel = await database.saveModel<T>(model);
    addLoadedModels([newModel]);
    return newModel;
  }
}
