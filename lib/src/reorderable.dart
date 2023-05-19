import 'dart:math';

import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

/// A [GenericModel] that has an [ordinal] parameter. When used with a
/// [ReorderableMap], by default greater ordinal values should be shown first.
///
/// This is to make it convenient to add a custom sort feature.
mixin OrdereableModel on GenericModel {
  /// Compared with other instances of [OrdereableModel] to set the custom sort.
  int get ordinal;
  set ordinal(int value);

  /// Add this to your implementation of the
  /// [getGetterSetterMap] function of [GenericModel]
  Tuple2<Getter<dynamic>, Setter<dynamic>> get ordinalGetterSetter =>
      Tuple2(() => ordinal, (val) => ordinal = val as int? ?? 0);
}

/// Records a movement of an [OrdereableModel].
class ListMovement<T extends OrdereableModel> {
  /// Records a movement of an [OrdereableModel]
  ListMovement(this.moved, this.to);

  /// The [OrdereableModel] that was moved.
  final T moved;

  /// The location in the list that [moved] was moved to.
  final int to;
}

/// Adds functions to [GenericModelMap] specifically for [OrdereableModel]
///
/// This is to make it more convenient to work with [OrdereableModel]s
extension ReorderableMap<T extends OrdereableModel> on GenericModelMap<T> {
  /// Automatically sets the ordinal of the given [model] based on the existing
  /// models in [map]
  T setOrdinalOfNewEntry(T model) {
    return model..ordinal = map.entries.length;
  }

  /// Returns a [List] of keys sorted based on the ordinal value of the
  /// [OrdereableModel]s in [map]
  List<String> get defaultOrderedKeyList => map.keys.toList()
    ..sort((a, b) => map[b]!.ordinal.compareTo(map[a]!.ordinal));

  /// Returns a [List] of [T] sorted based on the ordinal value of the
  /// [OrdereableModel]s in [map]
  List<T> get defaultOrderedList =>
      map.values.toList()..sort((a, b) => b.ordinal.compareTo(a.ordinal));

  /// Reorders the [model] to have the [newOrdinal] value for ordinal
  ///
  /// This will automatically change the ordinal value for the other [T] in
  /// [map]. This will also automatically update [repository]
  Future<Iterable<T>> reorder(
    T model,
    int newOrdinal, {
    String? databaseName,
  }) async {
    final list = defaultOrderedKeyList;

    final checkedOrdinal = min(newOrdinal, list.length);
    final initialOrdinal = list.indexOf(model.id!);

    if (checkedOrdinal == initialOrdinal) {
      return [];
    }

    final updatedModels = <T>{};

    for (var i = 0; i < list.length; i++) {
      final pastOldIndex = i >= initialOrdinal;
      final pastNewIndex = i >= checkedOrdinal;

      if (!pastOldIndex && !pastNewIndex) {
        continue;
      }
      if (pastNewIndex && pastOldIndex) {
        break;
      }
      final updatedModel = map[list[i]]!;
      updatedModels.add(updatedModel);
      if (pastNewIndex) {
        updatedModel.ordinal = list.length - i - 2;
      }
      if (pastOldIndex) {
        updatedModel.ordinal = list.length - i;
      }
    }
    updatedModels.add(model);
    model.ordinal = list.length -
        checkedOrdinal -
        (checkedOrdinal > initialOrdinal ? 0 : 1);

    return Future.wait(
      updatedModels.map((e) => updateModel(e, databaseName: databaseName)),
    );
  }
}
