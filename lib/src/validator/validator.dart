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

/// Runs a group of [Validator]s
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
