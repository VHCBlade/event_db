import 'package:event_db/event_db.dart';

/// Runs a [Validator] on each element in a given list.
class ListSubValidator implements Validator {
  /// [name] is traversed using [JsonMap.read] to find the base list
  ///
  /// [validator] is ran on each element in the sub list
  const ListSubValidator(this.name, {required this.validator});

  /// Ran on each element in the sub list
  final Validator validator;

  @override
  final String name;

  @override
  String get message => 'failed specific validator for list element: '
      '${validator.name} ${validator.message}';

  @override
  bool validate(Map<String, dynamic> map) {
    final value = map.read<List<dynamic>>(name);
    if (value == null) {
      return true;
    }

    for (var i = 0; i < value.length; i++) {
      if (!validator.validate(value[i] as Map<String, dynamic>)) {
        return false;
      }
    }
    return true;
  }
}

/// Ensures that a list has a number of elements within a specific range.
class ListSizeValidator implements Validator {
  /// [name] is traversed using [JsonMap.read] to find the base list
  ///
  /// [min] is the inclusive minimum number of elements in the list.
  ///
  /// [max] is the inclusive maximum number of elements in the list. If
  /// this is null, then there will be no maximum bound.
  const ListSizeValidator(
    this.name, {
    required this.min,
    this.max,
  });

  @override
  final String name;

  /// the inclusive minimum number of elements in the list.
  final int min;

  /// the inclusive maximum number of elements in the list. If
  /// this is null, then there will be no maximum bound.
  final int? max;
  @override
  String get message => 'does not contain the required number of elements $min '
      '${max == null ? '' : '- $max'}';

  @override
  bool validate(Map<String, dynamic> map) {
    final value = map.read<List<dynamic>>(name);
    if (value == null) {
      return true;
    }

    if (value.length < min) {
      return false;
    }
    return max == null || value.length <= max!;
  }
}
