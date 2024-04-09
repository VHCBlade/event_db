import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

/// R
enum DateTimeConversion {
  /// Converts [DateTime]s to microseconds
  microseconds,

  /// Converts [DateTime]s to milliseconds
  milliseconds,

  /// Converts [DateTime]s to seconds
  seconds,
  ;
}

final _dateTimeConstructors = {
  DateTimeConversion.microseconds: DateTime.fromMicrosecondsSinceEpoch,
  DateTimeConversion.milliseconds: DateTime.fromMillisecondsSinceEpoch,
  DateTimeConversion.seconds: (int value) =>
      DateTime.fromMillisecondsSinceEpoch(value * 1000),
};
final _dateTimeGetters = <DateTimeConversion, int Function(DateTime)>{
  DateTimeConversion.microseconds: (value) => value.microsecondsSinceEpoch,
  DateTimeConversion.milliseconds: (value) => value.millisecondsSinceEpoch,
  DateTimeConversion.seconds: (value) => value.millisecondsSinceEpoch ~/ 1000,
};

/// Base Class to be extended by
abstract class GenericModel extends MappableModel {
  /// The key for [type] in the result of [toMap]
  static const TYPE = 'type';

  /// The key for [id] in the result of [toMap]
  static const ID = 'id';

  @override
  String get idKey => ID;
  @override
  String get typeKey => TYPE;

  @override
  String get type;

  @override
  String? id;

  @override
  Map<String, dynamic> toMap() {
    final map = getterSetterMap.createMap();
    map[TYPE] = type;

    return map;
  }

  @override
  void loadFromMap(Map<String, dynamic> map, {bool respectType = true}) {
    if (respectType && map.containsKey(TYPE)) {
      if (map[TYPE] != type) {
        throw FormatException('Type in $map does not match $type');
      }
    }
    getterSetterMap.loadMap(map);
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
  /// appropriate serialized type.
  ///
  /// [conversion] sets what value will be saved in the final [Getter] and
  /// [Setter] based on existing [DateTime] value.
  static Tuple2<Getter<dynamic>, Setter<dynamic>> dateTime(
    Getter<DateTime?> getter,
    Setter<DateTime?> setter, {
    DateTimeConversion conversion = DateTimeConversion.microseconds,
  }) {
    final conversionGetter = _dateTimeGetters[conversion]!;
    final conversionConstructor = _dateTimeConstructors[conversion]!;
    return Tuple2(
      () {
        final gotten = getter();
        if (gotten == null) {
          return null;
        }
        return conversionGetter(gotten);
      },
      (val) => setter(
        val == null ? null : conversionConstructor(val as int),
      ),
    );
  }

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
