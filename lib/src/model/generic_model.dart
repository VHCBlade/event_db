import 'package:collection/collection.dart';
import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

/// Getter function to retrieve a field from a [GenericModel]
typedef Getter<T> = T Function();

/// Setter function to set a field in a [GenericModel]
typedef Setter<T> = void Function(T value);
final bool Function(dynamic, dynamic) _equality =
    const DeepCollectionEquality(DefaultEquality<dynamic>()).equals;

/// Base Class to be extended by
abstract class GenericModel implements BaseModel {
  /// The key for [type] in the result of [toMap]
  static const TYPE = 'type';

  /// The key for [id] in the result of [toMap]
  static const ID = 'id';

  @override
  String get type;

  @override
  String? id;

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map[TYPE] = type;
    getterSetterMap.keys
        .forEach((element) => map[element] = getterSetterMap[element]!.item1());

    return map;
  }

  @override
  void loadFromMap(Map<String, dynamic> map, {bool respectType = true}) {
    if (respectType && map.containsKey(TYPE)) {
      if (map[TYPE] != type) {
        throw FormatException('Type in $map does not match $type');
      }
    }
    getterSetterMap.keys
        .forEach((element) => getterSetterMap[element]!.item2(map[element]));
  }

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
        .forEach((element) => setField(element, model.getField(element)));
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
          (e) => _equality(getField(e), model.getField(e)),
        )
        .reduce((value, element) => value && element);
  }

  @override
  Iterable<String> get fieldKeys => getterSetterMap.keys;

  @override
  dynamic getField(String key) {
    return getterSetterMap[key]?.item1();
  }

  @override
  bool setField(String key, dynamic value) {
    if (!getterSetterMap.containsKey(key)) {
      return false;
    }
    getterSetterMap[key]!.item2(value);
    return true;
  }

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

  /// Implemented by subclasses to map the getters and setters of the object.
  ///
  /// Cannot have keys that have the values [TYPE] or [ID]
  Map<String, Tuple2<Getter<dynamic>, Setter<dynamic>>> getGetterSetterMap();

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
              (val as List<dynamic>?)
                  ?.map<T>(
                    (e) => supplier()..loadFromMap(e as Map<String, dynamic>),
                  )
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
