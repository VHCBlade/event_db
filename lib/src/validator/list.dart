import 'package:event_db/event_db.dart';

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
