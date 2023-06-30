import 'package:event_bloc/event_bloc.dart';
import 'package:event_db/src/exception.dart';
import 'package:event_db/src/fake.dart';
import 'package:test/test.dart';

void main() {
  test('Exception Stream', () async {
    var i = 0;
    final repository = FakeDatabaseRepository(constructors: {})
      ..initialize(
        BlocEventChannel(),
      );
    repository.errorStream.stream.listen((event) {
      i++;
    });

    repository.errorStream.add(
      const DatabaseException(
        database: 'cool',
        action: DatabaseAction.delete,
        error: DatabaseError.noDatabaseAccess,
      ),
    );

    await Future<void>.delayed(Duration.zero);
    expect(i, 1);

    repository.dispose();

    expect(
      () => repository.errorStream.add(
        const DatabaseException(
          database: 'cool',
          action: DatabaseAction.delete,
          error: DatabaseError.noDatabaseAccess,
        ),
      ),
      throwsStateError,
    );
    expect(i, 1);
  });
}
