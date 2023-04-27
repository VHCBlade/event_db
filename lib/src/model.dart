import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

typedef Getter<T> = T Function();
typedef Setter<T> = void Function(T value);

abstract class GenericModel {
  static const TYPE = 'type';
  static const ID = 'id';
  String? id;

  late final Map<String, Tuple2<Getter, Setter>> getterSetterMap =
      _getterSetterMap;
  Map<String, Tuple2<Getter, Setter>> get _getterSetterMap {
    final getterSetterMap = getGetterSetterMap();
    assert(!getterSetterMap.containsKey(TYPE));
    assert(!getterSetterMap.containsKey(ID));
    getterSetterMap[ID] = Tuple2(() => id, (val) => id = val);
    return getterSetterMap;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map[TYPE] = type;
    getterSetterMap.keys
        .forEach((element) => map[element] = getterSetterMap[element]!.item1());

    return map;
  }

  void loadFromMap(Map<String, dynamic> map, {bool respectType = true}) {
    if (respectType && map.containsKey(TYPE)) {
      if (map[TYPE] != type) {
        throw ArgumentError('Type in $map does not match $type');
      }
    }
    getterSetterMap.keys
        .forEach((element) => getterSetterMap[element]!.item2(map[element]));
  }

  /// Copies values from the given [model] into this model.
  ///
  /// If [allowDifferentTypes] is true, the method will continue even if the types and fields in [model] and myself are different. Otherwise, differences will be met with an error.
  ///
  /// [onlyFields] and [exceptFields] can be used to limit the fields that are copied. The two are mutually exclusive and an error will be thrown if both a specified.
  void copy<T extends GenericModel>(T model,
      {bool allowDifferentTypes = false,
      bool copyId = true,
      Iterable<String>? onlyFields,
      Iterable<String>? exceptFields}) {
    assert(onlyFields == null || exceptFields == null);
    if (!allowDifferentTypes) {
      assert(type == model.type);
    }
    final keysToBeCopied = getterSetterMap.keys.where((element) {
      if (onlyFields != null) {
        return onlyFields.contains(element);
      }
      if (exceptFields != null) {
        return !exceptFields.contains(element);
      }
      if (element == ID) {
        return copyId;
      }
      return true;
    }).where((element) => model.getterSetterMap.keys.contains(element));

    keysToBeCopied.forEach((element) {
      getterSetterMap[element]!.item2(model.getterSetterMap[element]!.item1());
    });
  }

  /// Returns [id] if that value is not null. Otherwise will automatically generate a new value for [id] with the [idSuffix] setter.
  String get autoGenId => id = id ?? prefixTypeForId(const Uuid().v4());

  String prefixTypeForId(String idSuffix) => '${type}::$idSuffix';

  set idSuffix(String? idSuffix) =>
      id = idSuffix == null ? null : prefixTypeForId(idSuffix);
  String? get idSuffix => id?.split('::').last;

  /// Implemented by subclasses to map the getters and setters of the object.
  ///
  /// Cannot have keys that have the values [TYPE] or [ID]
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap();

  /// Unique type to give to the model. Whether or not collision is expected is dependent on the parameters of your system.
  String get type;

  /// Converts the pair of [Getter] and [Setter] for an enum into the appropriate pair for storage (a String)
  ///
  /// [values] is the list of possible values that the enum has (ex. ExampleEnum.values)
  static Tuple2<Getter, Setter> convertEnumToString<T extends Enum>(
      Getter<T?> getter, Setter<T?> setter, Iterable<T> values) {
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
                orElse: () => null),
      ),
    );
  }

  /// Converts the pair of [Getter] and [Setter] for a [GenericModel] into the appropriate serialized type.
  ///
  /// [supplier] should generate a new mutable version of this [GenericModel]
  static Tuple2<Getter, Setter> model<T extends GenericModel>(
          Getter<T?> getter, Setter<T?> setter, Getter<T> supplier) =>
      Tuple2(() => getter()?.toMap(),
          (val) => setter(val == null ? null : (supplier()..loadFromMap(val))));

  /// Converts the pair of [Getter] and [Setter] for a [List] of [GenericModel] into the appropriate serialized type.
  ///
  /// [supplier] should generate a new mutable version of this [GenericModel]
  static Tuple2<Getter, Setter> modelList<T extends GenericModel>(
          Getter<List<T>?> getter,
          Setter<List<T>?> setter,
          Getter<T> supplier) =>
      Tuple2(
          () => getter()?.map((e) => e.toMap()).toList(),
          (val) =>
              setter(val?.map<T>((e) => supplier()..loadFromMap(e)).toList()));

  /// Converts the pair of [Getter] and [Setter] for a [Map] of [GenericModel] into the appropriate serialized type.
  ///
  /// [supplier] should generate a new mutable version of this [GenericModel]
  static Tuple2<Getter, Setter> modelMap<T extends GenericModel>(
          Getter<Map<String, T>?> getter,
          Setter<Map<String, T>?> setter,
          Getter<T> supplier) =>
      Tuple2(
          () => getter()?.map((key, value) => MapEntry(key, value.toMap())),
          (val) => setter(val?.map<String, T>((key, value) =>
              MapEntry("$key", supplier()..loadFromMap(value)))));

  /// Converts the pair of [Getter] and [Setter] for a [DateTime] into the appropriate serialized type. (microsecondsSinceEpoc)
  static Tuple2<Getter, Setter> dateTime(
          Getter<DateTime?> getter, Setter<DateTime?> setter) =>
      Tuple2(
          () => getter()?.microsecondsSinceEpoch,
          (val) => setter(
              val == null ? null : DateTime.fromMicrosecondsSinceEpoch(val)));

  /// Takes the pair of [Getter] and [Setter] for a primitive and puts them in a [Tuple2]. Convenience function if you don't want to
  /// rely on the tuple package directly.
  static Tuple2<Getter, Setter> primitive<T>(
          Getter<T?> getter, Setter<T?> setter) =>
      Tuple2(() => getter(), (val) => setter(val));
}
