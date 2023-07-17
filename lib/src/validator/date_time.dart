import 'package:event_db/event_db.dart';

/// Ensures that a [DateTime] in [name] is in the past.
class PastDateTimeValidator implements Validator {
  /// [name] is split using '.' and the map is traversed sequentially until the
  /// value is returned. Will Validate if that value is not true.
  const PastDateTimeValidator(this.name);

  @override
  final String name;
  @override
  String get message => 'needs to be in the past!';

  @override
  bool validate(Map<String, dynamic> map) {
    final value = map.read<int>(name);
    if (value == null) {
      return true;
    }

    return DateTime.fromMicrosecondsSinceEpoch(value).isBefore(DateTime.now());
  }
}
