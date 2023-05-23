import 'dart:convert';

import 'package:event_db/event_db.dart';

/// Adds [toJsonString] and [loadFromJsonString] methods to simplify working
/// with encoded json maps.
extension JsonStringModel on GenericModel {
  /// Serializes this model into a json Object map string.
  String toJsonString() => json.encode(toMap());

  /// Loads [encodedString] into this model's values.
  ///
  /// [encodedString] is assumed to be a json Object map string, presumedly
  /// created by a call to [toJsonString]
  void loadFromJsonString(String encodedString) =>
      loadFromMap(json.decode(encodedString) as Map<String, dynamic>);
}
