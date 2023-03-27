import 'package:flutter_test/flutter_test.dart';

import 'models.dart';

void main() {
  group("Generic Model", () {
    group("Getter Setter", () {
      test("Model", () {
        final model = ExampleCompoundModel()..model = ExampleModel();
        final model2 = ExampleCompoundModel();

        model.id = "20";
        model.model.id = "cool";
        model.model.object = "cool";
        model.model.myEnum = ExampleEnum.yes;

        model2.loadFromMap(model.toMap());

        expect(model2.model.object, model.model.object);
        expect(model2.id, model.id);
        expect(model2.model.myEnum, model.model.myEnum);
        expect(model2.model.id, model.model.id);

        model.model.object = "Great";

        expect(model2.model.object, isNot(model.model.object));
      });
      test("Model List", () {
        final model = ExampleCompoundModel()..model = ExampleModel();
        final model2 = ExampleCompoundModel();

        final innerModel = ExampleModel();

        innerModel.id = "cool";
        innerModel.object = "cool";
        innerModel.myEnum = ExampleEnum.yes;

        model.list.add(innerModel);

        model2.loadFromMap(model.toMap());

        expect(model2.list[0].object, model.list[0].object);
        expect(model2.list[0].myEnum, model.list[0].myEnum);
        expect(model2.list[0].id, model.list[0].id);

        model.list[0].object = "Great";

        expect(model2.list[0].object, isNot(model.list[0].object));
      });
      test("Model Map", () {
        final model = ExampleCompoundModel()..model = ExampleModel();
        final model2 = ExampleCompoundModel();

        final innerModel = ExampleModel();

        innerModel.id = "cool";
        innerModel.object = "cool";
        innerModel.myEnum = ExampleEnum.yes;

        model.map["0"] = innerModel;

        model2.loadFromMap(model.toMap());

        expect(model2.map["0"]!.object, model.map["0"]!.object);
        expect(model2.map["0"]!.myEnum, model.map["0"]!.myEnum);
        expect(model2.map["0"]!.id, model.map["0"]!.id);

        model.map["0"]!.object = "Great";

        expect(model2.map["0"]!.object, isNot(model.map["0"]!.object));
      });
    });
  });
}
