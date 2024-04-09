import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

enum ExampleEnum {
  yes,
  no,
  ;
}

class NumberModel extends GenericModel {
  int? intVal;
  double? doubleVal;

  @override
  Map<String, Tuple2<Getter<dynamic>, Setter<dynamic>>> getGetterSetterMap() =>
      {
        'int':
            GenericModel.number(() => intVal, (val) => intVal = val?.toInt()),
        'double': GenericModel.number(
          () => doubleVal,
          (val) => doubleVal = val?.toDouble(),
        ),
      };

  @override
  String get type => 'example';
}

class ExampleModel extends GenericModel {
  String? object;
  ExampleEnum? myEnum;
  DateTime dateTime = DateTime.now();

  @override
  Map<String, Tuple2<Getter<dynamic>, Setter<dynamic>>> getGetterSetterMap() =>
      {
        'object':
            GenericModel.primitive(() => object, (value) => object = value),
        'enum': GenericModel.convertEnumToString(
          () => myEnum,
          (val) => myEnum = val,
          ExampleEnum.values,
        ),
        'dateTime': GenericModel.dateTime(
          () => dateTime,
          (value) => dateTime = value ?? DateTime.now(),
        ),
      };

  @override
  String get type => 'example';
}

class ExampleConversionModel extends GenericModel {
  DateTime? dateTime = DateTime.now();
  DateTime? dateTimeMilliseconds = DateTime.now();
  DateTime? dateTimeSeconds = DateTime.now();

  @override
  Map<String, Tuple2<Getter<dynamic>, Setter<dynamic>>> getGetterSetterMap() =>
      {
        'dateTime': GenericModel.dateTime(
          () => dateTime,
          (value) => dateTime = value,
        ),
        'dateTimeMilliseconds': GenericModel.dateTime(
          () => dateTimeMilliseconds,
          (value) => dateTimeMilliseconds = value,
          conversion: DateTimeConversion.milliseconds,
        ),
        'dateTimeSeconds': GenericModel.dateTime(
          () => dateTimeSeconds,
          (value) => dateTimeSeconds = value,
          conversion: DateTimeConversion.seconds,
        ),
      };

  @override
  String get type => 'example';
}

class ExampleReorderableModel extends GenericModel with OrdereableModel {
  String? name;
  @override
  int ordinal = 0;

  @override
  Map<String, Tuple2<Getter<dynamic>, Setter<dynamic>>> getGetterSetterMap() =>
      {
        'ordinal': ordinalGetterSetter,
        'name': GenericModel.primitive(() => name, (value) => name = value),
      };

  @override
  String get type => 'Reorderable';
}

class ExampleCompoundModel extends GenericModel {
  late ExampleModel model;
  List<ExampleModel> list = [];
  Map<String, ExampleModel> map = {};

  @override
  Map<String, Tuple2<Getter<dynamic>, Setter<dynamic>>> getGetterSetterMap() =>
      {
        'model': GenericModel.model(
          () => model,
          (value) => model = value ?? ExampleModel(),
          ExampleModel.new,
        ),
        'list': GenericModel.modelList(
          () => list,
          (value) => list = value ?? [],
          ExampleModel.new,
        ),
        'map': GenericModel.modelMap(
          () => map,
          (value) => map = value ?? {},
          ExampleModel.new,
        ),
      };

  @override
  String get type => 'example-compound';
}
