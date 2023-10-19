import 'package:uuid/uuid.dart';

/// Contains the minimum requirements to be considered a model
abstract class BaseModel {
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
