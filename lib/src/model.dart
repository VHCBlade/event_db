import 'package:collection/collection.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

/// Getter function to retrieve a field from a [GenericModel]
typedef Getter<T> = T Function();

/// Setter function to set a field in a [GenericModel]
typedef Setter<T> = void Function(T value);
final bool Function(dynamic, dynamic) _equality =
    const DeepCollectionEquality(DefaultEquality<dynamic>()).equals;

/// Base Class to be extended by
abstract class GenericModel {
  /// The key for [type] in the result of [toMap]
  static const TYPE = 'type';

  /// The key for [id] in the result of [toMap]
  static const ID = 'id';

  /// Unique identifier for this model
  String? id;

  /// Used by [toMap] to generate the map
  late final Map<String, Tuple2<Getter<dynamic>, Setter<dynamic>>>
      getterSetterMap = _getterSetterMap;
  Map<String, Tuple2<Getter<dynamic>, Setter<dynamic>>> get _getterSetterMap {
    final getterSetterMap = getGetterSetterMap();
    assert(
      !getterSetterMap.containsKey(TYPE),
      '"$TYPE" is already used by GenericModel. Do not use it for extensions',
    );
    assert(
      !getterSetterMap.containsKey(ID),
      '"$ID" is already used by GenericModel. Do not use it for extensions',
    );
    getterSetterMap[ID] = Tuple2(() => id, (val) => id = val as String?);
    return getterSetterMap;
  }

  /// Converts this [GenericModel] into a Serializable Map.
  ///
  /// Can be coverted back into the Class version by calling [loadFromMap]
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map[TYPE] = type;
    getterSetterMap.keys
        .forEach((element) => map[element] = getterSetterMap[element]!.item1());

    return map;
  }

  /// Loads a Serializable map into the values of this [GenericModel]
  ///
  /// You can generate a value that can be passed into this by using [toMap]
  ///
  /// [respectType] will make a check to ensure that the TYPE entry is the same
  /// if true. This will throw an [FormatException] if they're not the same
  void loadFromMap(Map<String, dynamic> map, {bool respectType = true}) {
    if (respectType && map.containsKey(TYPE)) {
      if (map[TYPE] != type) {
        throw FormatException('Type in $map does not match $type');
      }
    }
    getterSetterMap.keys
        .forEach((element) => getterSetterMap[element]!.item2(map[element]));
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
  void copy<T extends GenericModel>(
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
          if (element == ID) {
            return copyId;
          }
          return true;
        })
        .where((element) => model.getterSetterMap.keys.contains(element))
        .forEach((element) {
          getterSetterMap[element]!
              .item2(model.getterSetterMap[element]!.item1());
        });
  }

  /// Returns whether the given [model] has the same given fields as this model.
  ///
  /// [onlyFields] and [exceptFields] can be used to limit the fields that are
  /// compared. The two are mutually exclusive and an error will be thrown if
  /// both are specified.
  bool hasSameFields<T extends GenericModel>({
    required T model,
    Iterable<String>? onlyFields,
    Iterable<String>? exceptFields,
  }) {
    return fieldsToEvaluate(onlyFields, exceptFields)
        .map(
          (e) => _equality(
            getterSetterMap[e]?.item1(),
            model.getterSetterMap[e]?.item1(),
          ),
        )
        .reduce((value, element) => value && element);
  }

  /// Returns the fields that exist in this model.
  ///
  /// [onlyFields] and [exceptFields] can be used to limit the fields that are
  /// evaluated. The two are mutually exclusive and an error will be thrown if
  /// both are specified.
  Iterable<String> fieldsToEvaluate<T extends GenericModel>(
    Iterable<String>? onlyFields,
    Iterable<String>? exceptFields,
  ) {
    assert(
      onlyFields == null || exceptFields == null,
      'onlyFields and exceptFields cannot both be specified at the same time',
    );
    return getterSetterMap.keys.where((element) {
      if (onlyFields != null) {
        return onlyFields.contains(element);
      }
      if (exceptFields != null) {
        return !exceptFields.contains(element);
      }
      return true;
    });
  }

  /// Returns [id] if that value is not null. Otherwise will automatically
  /// generate a new value for [id] with the [idSuffix] setter.
  String get autoGenId => id = id ?? prefixTypeForId(const Uuid().v4());

  /// Prefixes this [GenericModel]'s [type] to [idSuffix]
  String prefixTypeForId(String idSuffix) => '$type::$idSuffix';

  /// Sets the [id] to have [idSuffix] as a suffix. This will override the
  /// existing [id].
  set idSuffix(String? idSuffix) =>
      id = idSuffix == null ? null : prefixTypeForId(idSuffix);

  /// Returns the last part of this [id], which is always a unique identifier.
  ///
  /// Note that if multiple types are prefixed, none of those will be returned.
  String? get idSuffix => id?.split('::').last;

  /// Implemented by subclasses to map the getters and setters of the object.
  ///
  /// Cannot have keys that have the values [TYPE] or [ID]
  Map<String, Tuple2<Getter<dynamic>, Setter<dynamic>>> getGetterSetterMap();

  /// Unique type to give to the model. Whether or not collision is expected is
  /// dependent on the parameters of your system.
  String get type;

  /// Converts the pair of [Getter] and [Setter] for an enum into the
  /// appropriate pair for storage (a String)
  ///
  /// [values] is the list of possible values that the enum has
  /// (ex. ExampleEnum.values)
  static Tuple2<Getter<dynamic>, Setter<dynamic>>
      convertEnumToString<T extends Enum>(
    Getter<T?> getter,
    Setter<T?> setter,
    Iterable<T> values,
  ) {
    return Tuple2(
      () {
        final value = getter();
        return value?.name;
      },
      (val) => setter(
        val == null
            ? null
            : values.map<T?>((e) => e).firstWhere(
                  (element) => val == element?.name,
                  orElse: () => null,
                ),
      ),
    );
  }

  /// Converts the pair of [Getter] and [Setter] for a [GenericModel] into the
  /// appropriate serialized type.
  ///
  /// [supplier] should generate a new mutable version of this [GenericModel]
  static Tuple2<Getter<dynamic>, Setter<dynamic>> model<T extends GenericModel>(
    Getter<T?> getter,
    Setter<T?> setter,
    Getter<T> supplier,
  ) =>
      Tuple2(
        () => getter()?.toMap(),
        (val) => setter(
          val == null
              ? null
              : (supplier()..loadFromMap(val as Map<String, dynamic>)),
        ),
      );

  /// Converts the pair of [Getter] and [Setter] for a [List] of [GenericModel]
  /// into the appropriate serialized type.
  ///
  /// [supplier] should generate a new mutable version of this [GenericModel]
  static Tuple2<Getter<dynamic>, Setter<dynamic>>
      modelList<T extends GenericModel>(
    Getter<List<T>?> getter,
    Setter<List<T>?> setter,
    Getter<T> supplier,
  ) =>
          Tuple2(
            () => getter()?.map((e) => e.toMap()).toList(),
            (val) => setter(
              (val as List<Map<String, dynamic>>?)
                  ?.map<T>((e) => supplier()..loadFromMap(e))
                  .toList(),
            ),
          );

  /// Converts the pair of [Getter] and [Setter] for a [Map] of [GenericModel]
  /// into the appropriate serialized type.
  ///
  /// [supplier] should generate a new mutable version of this [GenericModel]
  static Tuple2<Getter<dynamic>, Setter<dynamic>>
      modelMap<T extends GenericModel>(
    Getter<Map<String, T>?> getter,
    Setter<Map<String, T>?> setter,
    Getter<T> supplier,
  ) =>
          Tuple2(
            () => getter()?.map((key, value) => MapEntry(key, value.toMap())),
            (val) => setter(
              (val as Map<String, dynamic>?)?.map<String, T>(
                (key, value) => MapEntry(
                  key,
                  supplier()..loadFromMap(value as Map<String, dynamic>),
                ),
              ),
            ),
          );

  /// Converts the pair of [Getter] and [Setter] for a [DateTime] into the
  /// appropriate serialized type. (microsecondsSinceEpoc)
  static Tuple2<Getter<dynamic>, Setter<dynamic>> dateTime(
    Getter<DateTime?> getter,
    Setter<DateTime?> setter,
  ) =>
      Tuple2(
        () => getter()?.microsecondsSinceEpoch,
        (val) => setter(
          val == null ? null : DateTime.fromMicrosecondsSinceEpoch(val as int),
        ),
      );

  /// Takes the pair of [Getter] and [Setter] for a primitive and puts them in
  /// a [Tuple2]. Convenience function if you don't want to rely on the tuple
  /// package directly.
  static Tuple2<Getter<dynamic>, Setter<dynamic>> primitive<T>(
    Getter<T?> getter,
    Setter<T?> setter,
  ) =>
      Tuple2(() => getter(), (val) => setter(val as T?));

  /// Takes the pair of [Getter] and [Setter] for a primitive and puts them in
  /// a [Tuple2]. Convenience function if you don't want to rely on the tuple
  /// package directly.
  static Tuple2<Getter<dynamic>, Setter<dynamic>> number(
    Getter<num?> getter,
    Setter<num?> setter,
  ) =>
      Tuple2(() => getter(), (val) => setter(val as num?));
}
