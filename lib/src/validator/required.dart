import 'package:event_db/event_db.dart';

/// Ensures that a [name] is present in the map.
class RequiredValidator implements Validator {
  /// [name] is split using '.' and the map is traversed sequentially until the
  /// value is returned. Will Validate if that value is not true.
  const RequiredValidator(this.name);

  @override
  final String name;
  @override
  String get message => 'is required!';

  @override
  bool validate(Map<String, dynamic> map) {
    return map.read<dynamic>(name) != null;
  }
}
