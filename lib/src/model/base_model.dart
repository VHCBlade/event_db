import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

final bool Function(dynamic, dynamic) _equality =
    const DeepCollectionEquality(DefaultEquality<dynamic>()).equals;

/// Getter function to retrieve a field from a [BaseModel]
typedef Getter<T> = T Function();

/// Setter function to set a field in a [BaseModel]
typedef Setter<T> = void Function(T value);

/// Contains the minimum requirements to be considered a model
abstract class BaseModel {
  /// Represents the field key used for the [id]
  String get idKey;

  /// Represents the field key used for the [type]
  String get typeKey;

  /// Unique identifier for this model
  String? id;

  /// Unique type to give to the model. Whether or not collision is expected is
  /// dependent on the parameters of your system.
  String get type;

  /// Converts this [BaseModel] into a Serializable Map.
  ///
  /// Can be coverted back into the Class version by calling [loadFromMap]
  Map<String, dynamic> toMap();

  /// Loads a Serializable map into the values of this [BaseModel]
  ///
  /// You can generate a value that can be passed into this by using [toMap]
  ///
  /// [respectType] will make a check to ensure that the TYPE entry is the same
  /// if true. This will throw an [FormatException] if they're not the same
  void loadFromMap(Map<String, dynamic> map, {bool respectType = true});

  /// Returns the value of the field with name [key] or null if [key] is not a
  /// field in this model.
  dynamic getField(String key);

  /// Sets the field with name [key] to the given [value]
  ///
  /// Returns true if successful and false if the [key] doesn't exist.
  bool setField(String key, dynamic value);

  /// Returns all the available field keys in this object.
  Iterable<String> get fieldKeys;
}

/// Provides convenience functions for interacting with the id and type of a
/// [BaseModel]
extension BaseModelIDExtension on BaseModel {
  /// Returns [id] if that value is not null. Otherwise will automatically
  /// generate a new value for [id] with the [idSuffix] setter.
  String get autoGenId => id = id ?? prefixTypeForId(const Uuid().v4());

  /// Prefixes this [BaseModel]'s [type] to [idSuffix]
  String prefixTypeForId(String idSuffix) => '$type::$idSuffix';

  /// Sets the [id] to have [idSuffix] as a suffix. This will override the
  /// existing [id].
  set idSuffix(String? idSuffix) =>
      id = idSuffix == null ? null : prefixTypeForId(idSuffix);

  /// Returns the last part of this [id], which is always a unique identifier.
  ///
  /// Note that if multiple types are prefixed, none of those will be returned.
  String? get idSuffix => id?.split('::').last;
}

/// Adds methods to [BaseModel] to help with performing operations on the fields
extension BaseModelFieldExtension on BaseModel {
  /// Returns the fields that exist in this model.
  ///
  /// [onlyFields] and [exceptFields] can be used to limit the fields that are
  /// evaluated. The two are mutually exclusive and an error will be thrown if
  /// both are specified.
  Iterable<String> fieldsToEvaluate<T extends BaseModel>(
    Iterable<String>? onlyFields,
    Iterable<String>? exceptFields,
  ) {
    assert(
      onlyFields == null || exceptFields == null,
      'onlyFields and exceptFields cannot both be specified at the same time',
    );
    return fieldKeys.where((element) {
      if (onlyFields != null) {
        return onlyFields.contains(element);
      }
      if (exceptFields != null) {
        return !exceptFields.contains(element);
      }
      return true;
    });
  }

  /// Returns whether the given [model] has the same given fields as this model.
  ///
  /// [onlyFields] and [exceptFields] can be used to limit the fields that are
  /// compared. The two are mutually exclusive and an error will be thrown if
  /// both are specified.
  bool hasSameFields<T extends BaseModel>({
    required T model,
    Iterable<String>? onlyFields,
    Iterable<String>? exceptFields,
  }) {
    return fieldsToEvaluate(onlyFields, exceptFields)
        .map(
          (e) => _equality(getField(e), model.getField(e)),
        )
        .reduce((value, element) => value && element);
  }

  /// Copies values from the given [model] into this model.
  ///
  /// If [allowDifferentTypes] is true, the method will continue even if the
  /// types and fields in [model] and myself are different. Otherwise,
  /// differences will be met with a [FormatException].
  ///
  /// [onlyFields] and [exceptFields] can be used to limit the fields that are
  /// copied. The two are mutually exclusive and an error will be thrown if both
  /// are specified.
  void copy<T extends BaseModel>(
    T model, {
    bool allowDifferentTypes = false,
    bool copyId = true,
    Iterable<String>? onlyFields,
    Iterable<String>? exceptFields,
  }) {
    if (!allowDifferentTypes) {
      if (type != model.type) {
        throw FormatException(
          'Types do not match! ("$type" and "${model.type}")',
        );
      }
    }
    fieldsToEvaluate(onlyFields, exceptFields)
        .where((element) {
          if (element == idKey) {
            return copyId;
          }
          return true;
        })
        .where((element) => model.fieldKeys.contains(element))
        .forEach((element) => setField(element, model.getField(element)));
  }
}
