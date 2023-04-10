import 'dart:math';

import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

/// A [GenericModel] that has an [ordinal] parameter. When used with a [ReorderableMap], by default greater ordinal values
/// should be shown first. This is to make it convenient to
mixin OrdereableModel on GenericModel {
  int get ordinal;
  set ordinal(int value);

  Tuple2<Getter, Setter> get ordinalGetterSetter =>
      Tuple2(() => ordinal, (val) => ordinal = val ?? 0);
}

class ListMovement<T extends OrdereableModel> {
  final T moved;
  final int to;

  ListMovement(this.moved, this.to);
}

extension ReorderableMap<T extends OrdereableModel> on GenericModelMap<T> {
  T setOrdinalOfNewEntry(T model) {
    return model..ordinal = map.entries.length;
  }

  List<String> get defaultOrderedKeyList => map.keys.toList()
    ..sort((a, b) => map[b]!.ordinal.compareTo(map[a]!.ordinal));
  List<T> get defaultOrderedList =>
      map.values.toList()..sort((a, b) => b.ordinal.compareTo(a.ordinal));

  Future<Iterable<T>> reorder(T model, int newOrdinal,
      {String? databaseName}) async {
    final list = defaultOrderedKeyList;

    newOrdinal = min(newOrdinal, list.length);
    final initialOrdinal = list.indexOf(model.id!);

    if (newOrdinal == initialOrdinal) {
      return [];
    }

    final updatedModels = <T>{};

    for (int i = 0; i < list.length; i++) {
      final pastOldIndex = i >= initialOrdinal;
      final pastNewIndex = i >= newOrdinal;

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
    model.ordinal =
        list.length - newOrdinal - (newOrdinal > initialOrdinal ? 0 : 1);

    return await Future.wait(
        updatedModels.map((e) => updateModel(e, databaseName: databaseName)));
  }
}
