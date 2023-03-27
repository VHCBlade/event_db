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

  @override
  Map<String, Tuple2<Getter, Setter>> getGetterSetterMap() => {
        "object": Tuple2(() => object, (val) => object = val),
        "enum": GenericModel.convertEnumToString(
            () => myEnum, (val) => myEnum = val, ExampleEnum.values)
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
  String get type => "example";
}
