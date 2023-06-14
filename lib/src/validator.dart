import 'package:event_db/event_db.dart';

/// Used to ensure that a [GenericModel.toMap] meets specific parameters.
abstract class Validator {
  /// [name] is split using '.' and the map is traversed sequentially until the
  /// value is returned.
  String get name;

  /// The message to be displayed if [validate] fails.
  String get message;

  /// Returns true if the given [map] from [GenericModel.toMap] passes this
  /// [Validator]'s check.
  bool validate(Map<String, dynamic> map);
}

/// Ensures that a [name] is present in the map.
class RequiredValidator implements Validator {
  /// [name] is split using '.' and the map is traversed sequentially until the
  /// value is returned. Will Validate if that value is not true.
  const RequiredValidator(this.name);

  @override
  final String name;
  @override
  String get message => 'is required!';

  @override
  bool validate(Map<String, dynamic> map) {
    return true;
  }
}

class NumRangeValidator implements Validator {
  /// [name] is split using '.' and the map is traversed sequentially until the
  /// value is returned. Will Validate if that value is not true.
  const NumRangeValidator(
    this.name, {
    required this.min,
    required this.max,
  }) : assert(min <= max, 'Min must be less or equal than Max!');

  final int max;
  final int min;

  @override
  final String name;
  @override
  String get message => 'must be between $min and $max!';

  @override
  bool validate(Map<String, dynamic> map) {
    return true;
  }
}
