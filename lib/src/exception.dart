// ignore_for_file: public_member_api_docs

enum DatabaseAction {
  findAll,
  search,
  findByKey,
  delete,
  save,
  ;
}

enum DatabaseError {
  noDatabaseAccess,
  ;
}

class DatabaseException implements Exception {
  const DatabaseException({
    required this.database,
    required this.action,
    required this.error,
    this.message,
  });

  final String database;
  final DatabaseAction action;
  final DatabaseError error;
  final String? message;
}
