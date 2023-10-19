import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

/// Maps fields to their appropriate field key given/to a map
typedef MappableFields = Map<String, Tuple2<Getter<dynamic>, Setter<dynamic>>>;

/// Indicates that the [BaseModel] has a [MappableFields] object that MUST be
/// implemented and can then be used to map the fields in this object into a
/// Map
abstract class MappableModel implements BaseModel {
  /// Used by [toMap] to generate the map
  late final MappableFields getterSetterMap = _getterSetterMap;
  MappableFields get _getterSetterMap {
    final getterSetterMap = getGetterSetterMap();
    assert(
      !getterSetterMap.containsKey(typeKey),
      '"$typeKey" is already used by GenericModel. Do not use it for extensions',
    );
    assert(
      !getterSetterMap.containsKey(idKey),
      '"$idKey" is already used by GenericModel. Do not use it for extensions',
    );
    getterSetterMap[idKey] = Tuple2(() => id, (val) => id = val as String?);
    return getterSetterMap;
  }

  /// Implemented by subclasses to map the getters and setters of the object.
  ///
  /// Cannot have keys that have the values [typeKey] or [idKey]
  MappableFields getGetterSetterMap();
}

/// Adds the [createMap] and [loadMap] functions to conveniently perform the
/// actions of [MappableFields]
extension MapFieldsExtension on MappableFields {
  /// Creates a new [Map] with the current values generated by the [Getter]s
  Map<String, dynamic> createMap() {
    final map = <String, dynamic>{};
    keys.forEach((element) => map[element] = this[element]!.item1());

    return map;
  }

  /// Loads the shallow values of the given [map] into the stored [Setter]s
  void loadMap(Map<String, dynamic> map) {
    keys.forEach((element) => this[element]!.item2(map[element]));
  }
}
