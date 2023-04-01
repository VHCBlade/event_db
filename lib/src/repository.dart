import 'dart:async';

import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/src/model.dart';

abstract class DatabaseRepository extends Repository {
  /// This functions finds all models of the given type that have their [id] start with the prefix given by the [supplier]s [prefixTypeForId]
  FutureOr<Iterable<T>> findAllModelsOfType<T extends GenericModel>(
      String database, T Function() supplier);

  FutureOr<T?> findModel<T extends GenericModel>(String database, String key);

  FutureOr<bool> deleteModel<T extends GenericModel>(String database, T model);

  FutureOr<T> saveModel<T extends GenericModel>(String database, T model);

  /// Finds all the models in the given [database] that have the given [keys]
  ///
  /// The default implementation simply calls [findModel] multiple times. A concrete implementation with a more efficient
  /// way of doing this should override this function.
  FutureOr<Iterable<T>> findModels<T extends GenericModel>(
          String database, Iterable<String> keys) async =>
      (await Future.wait(keys.map((e) async => findModel<T>(database, e))))
          .where((element) => element != null)
          .map((e) => e!)
          .toList();
}

class SpecificDatabase {
  final DatabaseRepository database;
  final String databaseName;

  SpecificDatabase(this.database, this.databaseName);

  /// This functions finds all models of the given type that have their [id] start with the prefix given by the [supplier]s [prefixTypeForId]
  FutureOr<Iterable<T>> findAllModelsOfType<T extends GenericModel>(
          T Function() supplier) =>
      database.findAllModelsOfType(databaseName, supplier);

  FutureOr<T?> findModel<T extends GenericModel>(String key) =>
      database.findModel(databaseName, key);

  FutureOr<bool> deleteModel<T extends GenericModel>(T model) =>
      database.deleteModel(databaseName, model);

  FutureOr<T> saveModel<T extends GenericModel>(T model) =>
      database.saveModel(databaseName, model);

  FutureOr<Iterable<T>> findModels<T extends GenericModel>(
          Iterable<String> keys) =>
      database.findModels<T>(databaseName, keys);
}
