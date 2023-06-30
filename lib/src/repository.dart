import 'dart:async';

import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/src/exception.dart';
import 'package:event_db/src/model.dart';

/// Represents a class that implements some specific implementation of an
/// interface with storage. Classes that implement this must retain data
/// that is saved using the various functions such as [saveModel] and be
/// retrieved using [findModel] in a separate session.
abstract class DatabaseRepository extends Repository {
  /// This functions finds all models of the given type that have their
  /// [GenericModel.id] start with the prefix given by the [supplier]s
  /// [GenericModel.prefixTypeForId]
  FutureOr<Iterable<T>> findAllModelsOfType<T extends GenericModel>(
    String database,
    T Function() supplier,
  );

  /// Listen for [DatabaseException]s that occur from trying to access this
  /// database.
  late final errorStream = StreamController<DatabaseException>.broadcast();

  /// Finds the [T] model in [database] with id of [key].
  FutureOr<T?> findModel<T extends GenericModel>(String database, String key);

  /// Deletes the [T] [model] in [database]. [model] doesn not need to be
  /// exactly the same, just have the same id.
  FutureOr<bool> deleteModel<T extends GenericModel>(String database, T model);

  /// Saves the [T] [model] in [database]. [model]s that do not have an existing
  /// id will have one automatically assigned to them. This function doesn't
  /// care if there is an already existing model or not. Existing models will
  /// just be overridden
  FutureOr<T> saveModel<T extends GenericModel>(String database, T model);

  /// Finds all the models in the given [database] that have the given [keys]
  ///
  /// The default implementation simply calls [findModel] multiple times.
  /// A concrete implementation with a more efficient way of doing this should
  /// override this function.
  FutureOr<Iterable<T>> findModels<T extends GenericModel>(
    String database,
    Iterable<String> keys,
  ) async =>
      (await Future.wait(keys.map((e) async => findModel<T>(database, e))))
          .where((element) => element != null)
          .map((e) => e!)
          .toList();

  /// Finds all models in [database] that have values that match the passed
  /// [model]'s values
  ///
  /// Only values that are mapped to keys in [fields] will be considered.
  ///
  /// The default implementation is to call [findAllModelsOfType]s and then
  /// perform a comparison individiually.
  ///
  /// A concrete implementation with a more efficient way of doing this should
  /// override this function.
  FutureOr<Iterable<T>> searchByModelAndFields<T extends GenericModel>(
    String database,
    T Function() supplier,
    T model,
    List<String> fields,
  ) async {
    final values = await findAllModelsOfType(database, supplier);
    return values.where(
      (element) => model.hasSameFields(
        model: element,
        onlyFields: fields,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    errorStream.close();
  }
}

/// Wraps a [DatabaseRepository] with all of the databaseFunctions having a
/// given [databaseName] automatically passed as the database argument.
class SpecificDatabase {
  /// [database] has all of the underlying database implementation for all of
  /// the database functions of this object.
  ///
  /// [databaseName] is the value passed as the database in all of the database
  /// functions of this object.
  SpecificDatabase(this.database, this.databaseName);

  /// The underlying database implementation for all of the functions of this
  /// object.
  final DatabaseRepository database;

  /// The value passed as the database in all of the database functions of this
  /// object.
  final String databaseName;

  /// This functions finds all models of the given type that have their
  /// [GenericModel.id] start with the prefix given by the [supplier]s
  /// [GenericModel.prefixTypeForId]
  FutureOr<Iterable<T>> findAllModelsOfType<T extends GenericModel>(
    T Function() supplier,
  ) =>
      database.findAllModelsOfType(databaseName, supplier);

  /// Finds the [T] model in [databaseName] with id of [key].
  FutureOr<T?> findModel<T extends GenericModel>(String key) =>
      database.findModel(databaseName, key);

  /// Deletes the [T] [model] in [databaseName]. [model] doesn not need to be
  /// exactly the same, just have the same id.
  FutureOr<bool> deleteModel<T extends GenericModel>(T model) =>
      database.deleteModel(databaseName, model);

  /// Saves the [T] [model] in [databaseName]. [model]s that do not have an
  /// existing id will have one automatically assigned to them. This function
  /// doesn't  care if there is an already existing model or not. Existing
  /// models will just be overridden
  FutureOr<T> saveModel<T extends GenericModel>(T model) =>
      database.saveModel(databaseName, model);

  /// Finds all the models in [databaseName] that have the given [keys]
  FutureOr<Iterable<T>> findModels<T extends GenericModel>(
    Iterable<String> keys,
  ) =>
      database.findModels<T>(databaseName, keys);

  /// Finds all models in [databaseName] that have values that match the passed
  /// [model]'s values
  ///
  /// Only values that are mapped to keys in [fields] will be considered.
  ///
  /// The default implementation is to call [findAllModelsOfType]s and then
  /// perform a comparison individiually.
  ///
  /// A concrete implementation with a more efficient way of doing this should
  /// override this function.
  FutureOr<Iterable<T>> searchByModelAndFields<T extends GenericModel>(
    T Function() supplier,
    T model,
    List<String> fields,
  ) async {
    return await database.searchByModelAndFields(
      databaseName,
      supplier,
      model,
      fields,
    );
  }
}
