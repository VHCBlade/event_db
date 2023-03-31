import 'package:test/test.dart';

import 'models.dart';

void main() {
  group("To and From Map", () {
    test("Simple", () {
      final model = ExampleModel();
      final model2 = ExampleModel();

      model.id = "20";
      model.object = "cool";

      model2.loadFromMap(model.toMap());

      expect(model2.object, model.object);
      expect(model2.id, model.id);
    });
    test("Enum", () {
      final model = ExampleModel();
      final model2 = ExampleModel();

      model.id = "20";
      model.object = "cool";
      model.myEnum = ExampleEnum.yes;

      model2.loadFromMap(model.toMap());

      expect(model2.object, model.object);
      expect(model2.id, model.id);
      expect(model2.myEnum, model.myEnum);
    });
    test("Date Time", () {
      final model = ExampleModel();
      final model2 = ExampleModel();

      model.id = "20";
      model.object = "cool";
      model.myEnum = ExampleEnum.yes;
      model.dateTime = DateTime(1970, 5);

      model2.loadFromMap(model.toMap());

      expect(model2.object, model.object);
      expect(model2.id, model.id);
      expect(model2.myEnum, model.myEnum);
      expect(model.dateTime, model2.dateTime);
    });
  });
  group("Copy", () {
    test("Basic", () {
      final model = ExampleModel();
      final model2 = ExampleModel();

      model.id = "20";
      model.object = "cool";

      model2.copy(model);

      expect(model2.object, model.object);
      expect(model2.id, model.id);
    });
    test("Only Fields", () {
      final model = ExampleModel();
      final model2 = ExampleModel();

      model.id = "20";
      model.object = "cool";

      model2.copy(model, onlyFields: ["object"]);

      expect(model2.object, model.object);
      expect(model2.id, null);
    });
    test("Except Fields", () {
      final model = ExampleModel();
      final model2 = ExampleModel();

      model.id = "20";
      model.object = "cool";

      model2.copy(model, exceptFields: ["object"]);

      expect(model2.id, model.id);
      expect(model2.object, null);
    });
  });

  group("Id Suffix", () {
    test("Generate", () {
      final model = ExampleModel();
      final model2 = ExampleModel();

      expect(model.autoGenId, startsWith(ExampleModel().type));
      expect(model2.autoGenId, startsWith(ExampleModel().type));

      expect(model.autoGenId, model.id);
      expect(model2.autoGenId, model2.id);
    });
    test("Already Existing", () {
      final model = ExampleModel();
      final model2 = ExampleModel();

      model.id = "20";
      model2.id = "great";

      expect(model.autoGenId, "20");
      expect(model2.autoGenId, "great");
    });
  });
}
