import 'package:event_db/event_db.dart';
import 'package:flutter_test/flutter_test.dart';

import 'models.dart';

void main() {
  group('Generic Model', () {
    group('Getter Setter', () {
      test('Model', () {
        final model = ExampleCompoundModel()..model = ExampleModel();
        final model2 = ExampleCompoundModel();

        model.id = '20';
        model.model.id = 'cool';
        model.model.object = 'cool';
        model.model.myEnum = ExampleEnum.yes;

        model2.loadFromMap(model.toMap());

        expect(model2.model.object, model.model.object);
        expect(model2.id, model.id);
        expect(model2.model.myEnum, model.model.myEnum);
        expect(model2.model.id, model.model.id);

        model.model.object = 'Great';

        expect(model2.model.object, isNot(model.model.object));
      });
      test('Nullable Model', () {
        final model = ExampleCompoundModel()..model = ExampleModel();
        final model2 = ExampleCompoundModel();

        model.id = '20';
        model.model.id = 'cool';
        model.model.object = 'cool';
        model.model.myEnum = ExampleEnum.yes;

        model2.loadFromMap(model.toMap()..['model'] = null);

        expect(model2.id, model.id);

        model.model.object = 'Great';

        expect(model2.model.object, isNot(model.model.object));
      });
      test('Model List', () {
        final model = ExampleCompoundModel()..model = ExampleModel();
        final model2 = ExampleCompoundModel();

        final innerModel = ExampleModel()
          ..id = 'cool'
          ..object = 'cool'
          ..myEnum = ExampleEnum.yes;

        model.list.add(innerModel);

        model2.loadFromMap(model.toMap());

        expect(model2.list[0].object, model.list[0].object);
        expect(model2.list[0].myEnum, model.list[0].myEnum);
        expect(model2.list[0].id, model.list[0].id);

        model.list[0].object = 'Great';

        expect(model2.list[0].object, isNot(model.list[0].object));

        model2.loadFromJsonString(model.toJsonString());

        expect(model2.list[0].object, model.list[0].object);
        expect(model2.list[0].myEnum, model.list[0].myEnum);
        expect(model2.list[0].id, model.list[0].id);
      });
      test('Model Map', () {
        final model = ExampleCompoundModel()..model = ExampleModel();
        final model2 = ExampleCompoundModel();

        final innerModel = ExampleModel()
          ..id = 'cool'
          ..object = 'cool'
          ..myEnum = ExampleEnum.yes;

        model.map['0'] = innerModel;

        model2.loadFromMap(model.toMap());

        expect(model2.map['0']!.object, model.map['0']!.object);
        expect(model2.map['0']!.myEnum, model.map['0']!.myEnum);
        expect(model2.map['0']!.id, model.map['0']!.id);

        model.map['0']!.object = 'Great';

        expect(model2.map['0']!.object, isNot(model.map['0']!.object));

        model2.loadFromJsonString(model.toJsonString());

        expect(model2.map['0']!.object, model.map['0']!.object);
        expect(model2.map['0']!.myEnum, model.map['0']!.myEnum);
        expect(model2.map['0']!.id, model.map['0']!.id);
      });
      test('DateTime Conversion', () {
        final model = ExampleConversionModel();
        final model2 = ExampleConversionModel();

        model
          ..dateTime = DateTime.utc(1980)
          ..dateTimeMilliseconds = DateTime.utc(1990)
          ..dateTimeSeconds = DateTime.utc(2000);

        model2.copy(model);

        expect(model.dateTime?.isAtSameMomentAs(model2.dateTime!), true);
        expect(
          model.dateTimeMilliseconds
              ?.isAtSameMomentAs(model2.dateTimeMilliseconds!),
          true,
        );
        expect(
          model.dateTimeSeconds?.isAtSameMomentAs(model2.dateTimeSeconds!),
          true,
        );

        expect(model2.toMap()['dateTimeMilliseconds'], 631152000000);
        expect(model2.toMap()['dateTimeSeconds'], 946684800);

        model
          ..dateTime = null
          ..dateTimeMilliseconds = null
          ..dateTimeSeconds = null;

        model2.copy(model);

        expect(model2.dateTime, null);
        expect(model2.dateTimeMilliseconds, null);
        expect(model2.dateTimeSeconds, null);
      });
      test('Type Exception', () {
        final model = ExampleCompoundModel()..model = ExampleModel();
        final model2 = ExampleModel();

        model.id = '20';
        model.model.id = 'cool';
        model.model.object = 'cool';
        model.model.myEnum = ExampleEnum.yes;

        expect(
          () => model2.loadFromMap(model.toMap()),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}
