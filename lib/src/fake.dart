import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';

/// Represents a constructor specifically for [BaseModel]
typedef ModelConstructor<T extends BaseModel> = T Function();

/// A [DatabaseRepository] that stores everything in memory
///
/// This is best used in unit tests
class FakeDatabaseRepository extends DatabaseRepository {
  /// [constructors] holds all of the [ModelConstructor]s that can be found in
  /// this repository.
  FakeDatabaseRepository({required this.constructors});

  /// [constructors] holds all of the [ModelConstructor]s that can be found in
  /// this repository.
  final Map<Type, ModelConstructor> constructors;

  /// The "Storage" of this database
  Map<String, Map<String, BaseModel>> fakeDatabaseMap = {};

  @override
  bool deleteModel<T extends BaseModel>(String database, T model) {
    if (model.id == null) {
      return false;
    }

    return getMap(database).remove(model.id) != null;
  }

  @override
  Iterable<T> findAllModelsOfType<T extends BaseModel>(
    String database,
    T Function() supplier,
  ) {
    final modelBase = supplier();
    final keyPrefix = modelBase.prefixTypeForId('');

    return getMap(database)
        .entries
        .where((element) => element.value.id!.startsWith(keyPrefix))
        .map((e) => supplier()..copy(e.value));
  }

  @override
  T? findModel<T extends BaseModel>(String database, String key) {
    final baseModel = getMap(database)[key];
    if (baseModel == null) {
      return null;
    }

    return getInstance<T>()..copy(baseModel);
  }

  @override
  List<BlocEventListener<dynamic>> generateListeners(BlocEventChannel channel) {
    // DO NOTHING
    return [];
  }

  @override
  T saveModel<T extends BaseModel>(String database, T model) {
    final map = getMap(database);

    map[model.autoGenId] = getInstance<T>()..copy(model);

    return model;
  }

  /// Creates an instance using one of the [constructors]
  ///
  /// Will throw an [ArgumentError] if one isn't present in [constructors]
  /// for [T]
  T getInstance<T>() {
    if (!constructors.containsKey(T)) {
      throw ArgumentError(
          '$T was not added to the constructors of this FakeDatabaseRepository.'
          ' Please ensure you add all constructors you want to use for each '
          'type you will use.');
    }
    return constructors[T]!() as T;
  }

  /// Gets the "Storage" map for the given [database]
  Map<String, BaseModel> getMap(String database) {
    if (fakeDatabaseMap[database] == null) {
      fakeDatabaseMap[database] = {};
    }

    return fakeDatabaseMap[database]!;
  }
}
