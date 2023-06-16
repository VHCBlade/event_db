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

///
class ValidatorCollection {
  /// [validators] are all run simultaneously in [assertValidate]
  const ValidatorCollection(this.validators);

  /// These are the validators that are all run simultaneously in
  /// [assertValidate]
  final List<Validator> validators;

  /// If any of the [validators] fail with the given [map], a
  /// [ValidationCollectionException] will be thrown with all the offending
  /// [ValidationException]s
  void assertValidate(Map<String, dynamic> map) {
    final exceptions = <ValidationException>[];
    for (final validator in validators) {
      try {
        validator.assertValidate(map);
      } on ValidationException catch (e) {
        exceptions.add(e);
      }
    }
    if (exceptions.isEmpty) {
      return;
    }
    throw ValidationCollectionException(exceptions);
  }
}

/// Exception thrown by [ValidatorCollection] when any of its [Validator]s
/// throw an exception. All the [exceptions] thrown can be seen here.
class ValidationCollectionException implements Exception {
  /// [exceptions] are the exceptions that were thrown for this.
  const ValidationCollectionException(this.exceptions);

  /// The group of exceptions thrown.
  final List<ValidationException> exceptions;
}

/// The exception thrown when a [Validator] fails.
class ValidationException implements Exception {
  /// [name] and [baseMessage] give values for [message]
  const ValidationException(this.name, this.baseMessage);

  /// The message to be displayed for the user.
  String get message => '$name $baseMessage';

  /// The name in the JSON Map.
  final String name;

  /// The message to be shown to the user.
  final String baseMessage;
}

/// Adds common functions for Validators
extension ValidatorCommons on Validator {
  /// Uses [validate] and will throw a [ValidationException] for false values.
  void assertValidate(Map<String, dynamic> map) {
    final valid = validate(map);
    if (!valid) {
      throw ValidationException(name, message);
    }
  }
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
    return map.read<dynamic>(name) != null;
  }
}

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
