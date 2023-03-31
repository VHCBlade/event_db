import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/event_db.dart';

typedef ModelConstructor<T extends GenericModel> = T Function();

class FakeDatabaseRepository extends DatabaseRepository {
  final Map<Type, ModelConstructor> constructors;

  Map<String, Map<String, GenericModel>> fakeDatabaseMap = {};

  FakeDatabaseRepository({required this.constructors});

  @override
  bool deleteModel<T extends GenericModel>(String database, T model) {
    if (model.id == null) {
      return false;
    }

    return getMap(database).remove(model.id) != null;
  }

  @override
  Iterable<T> findAllModelsOfType<T extends GenericModel>(
      String database, T Function() supplier) {
    final modelBase = supplier();
    final keyPrefix = modelBase.prefixTypeForId("");

    return getMap(database)
        .entries
        .where((element) => element.value.id!.startsWith(keyPrefix))
        .map((e) => supplier()..copy(e.value));
  }

  @override
  T? findModel<T extends GenericModel>(String database, String key) {
    final baseModel = getMap(database)[key];
    if (baseModel == null) {
      return null;
    }

    return getInstance<T>()..copy(baseModel);
  }

  @override
  List<BlocEventListener> generateListeners(BlocEventChannel channel) {
    // DO NOTHING
    return [];
  }

  @override
  T saveModel<T extends GenericModel>(String database, T model) {
    final map = getMap(database);

    map[model.autoGenId] = getInstance<T>()..copy(model);

    return model;
  }

  T getInstance<T>() {
    if (!constructors.containsKey(T)) {
      throw ArgumentError(
          "$T was not added to the constructors of this FakeDatabaseRepository. Please ensure you add all constructors you want to use for each type you will use.");
    }
    return constructors[T]!() as T;
  }

  Map<String, GenericModel> getMap(String database) {
    if (fakeDatabaseMap[database] == null) {
      fakeDatabaseMap[database] = {};
    }

    return fakeDatabaseMap[database]!;
  }
}
