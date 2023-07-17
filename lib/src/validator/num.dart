import 'package:event_db/event_db.dart';

/// Validates that a value falls within a certain range. Will return true if the
/// value is not present.
class NumRangeValidator implements Validator {
  /// [name] is split using '.' and the map is traversed sequentially until the
  /// value is returned. Will Validate if that value is not true.
  ///
  /// [min] and [max] set the range, both inclusive.
  const NumRangeValidator(
    this.name, {
    required this.min,
    required this.max,
  }) : assert(min <= max, 'Min must be less or equal than Max!');

  /// The inclusive maximum of this range.
  final num max;

  /// The inclusive minimum of this range.
  final num min;

  @override
  final String name;
  @override
  String get message => 'must be between $min and $max!';

  @override
  bool validate(Map<String, dynamic> map) {
    final val = map.read<num>(name);
    if (val == null) {
      return true;
    }
    return val >= min && val <= max;
  }
}
