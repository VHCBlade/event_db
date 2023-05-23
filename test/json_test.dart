import 'package:event_db/event_db.dart';
import 'package:test/test.dart';

import 'models.dart';

void main() {
  group('JsonStringModel', () {
    test('to and from json string', () {
      final model = ExampleModel();
      final model2 = ExampleModel();

      model
        ..id = '20'
        ..object = 'cool';

      model2.loadFromJsonString(model.toJsonString());

      expect(model2.object, model.object);
      expect(model2.id, model.id);
    });
  });
}
