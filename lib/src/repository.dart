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
}
