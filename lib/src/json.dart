import 'dart:convert';

import 'package:event_db/event_db.dart';

/// Adds [toJsonString] and [loadFromJsonString] methods to simplify working
/// with encoded json maps.
extension JsonStringModel on BaseModel {
  /// Serializes this model into a json Object map string.
  String toJsonString() => json.encode(toMap());

  /// Loads [encodedString] into this model's values.
  ///
  /// [encodedString] is assumed to be a json Object map string, presumedly
  /// created by a call to [toJsonString]
  void loadFromJsonString(String encodedString) =>
      loadFromMap(json.decode(encodedString) as Map<String, dynamic>);
}

/// Extension on [Map] to make it easier to use as a json map.
extension JsonMap on Map<String, dynamic> {
  /// [name] is split using '.' and the map is traversed sequentially until the
  /// value is returned. Throws an ArgumentError if [T] does not match the value
  /// found.
  ///
  /// If an integer is found, it will
  T? read<T>(String name) {
    final splitName = name.split('.');
    dynamic value = this;

    for (final subName in splitName) {
      value = _traverse(subName, value);
    }

    if (value == null) {
      return null;
    }

    if (value is! T) {
      throw ArgumentError('$value is not a $T!');
    }

    return value;
  }
}

dynamic _traverse(String name, dynamic value) {
  if (value == null) {
    return null;
  }
  final intName = int.tryParse(name);
  if (intName != null) {
    if (value is! List<dynamic>) {
      return null;
    }
    if (value.length <= intName) {
      return null;
    }
    return value[intName];
  }
  if (value is! Map<String, dynamic>) {
    return null;
  }
  return value[name];
}
