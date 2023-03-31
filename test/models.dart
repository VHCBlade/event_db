import 'package:event_db/event_db.dart';
import 'package:tuple/tuple.dart';

enum ExampleEnum {
  yes,
  no,
  ;
}

class ExampleModel extends GenericModel {
  String? object;
  ExampleEnum? myEnum;
  DateTime dateTime = DateTime.now();

  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        "object":
            GenericModel.primitive(() => object, (value) => object = value),
        "enum": GenericModel.convertEnumToString(
            () => myEnum, (val) => myEnum = val, ExampleEnum.values),
        "dateTime": GenericModel.dateTime(
            () => dateTime, (value) => dateTime = value ?? DateTime.now()),
      };

  @override
  String get type => "example";
}

class ExampleCompoundModel extends GenericModel {
  late ExampleModel model;
  List<ExampleModel> list = [];
  Map<String, ExampleModel> map = {};

  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        "model": GenericModel.model(() => model,
            (value) => model = value ?? ExampleModel(), () => ExampleModel()),
        "list": GenericModel.modelList(
            () => list, (value) => list = value ?? [], () => ExampleModel()),
        "map": GenericModel.modelMap(
            () => map, (value) => map = value ?? {}, () => ExampleModel()),
      };

  @override
  String get type => "example-compound";
}
