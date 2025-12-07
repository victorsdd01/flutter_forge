import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text()();
  TextColumn get name => text().nullable()();
  TextColumn get token => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: <Type>[Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<User?> getUserByEmail(String email) async {
    final SimpleSelectStatement<$UsersTable, User> query = select(users)..where((Users u) => u.email.equals(email));
    return await query.getSingleOrNull();
  }

  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);

  Future<bool> updateUser(User user) async {
    await (update(users)..where((Users u) => u.id.equals(user.id))).replace(user);
    return true;
  }

  Future<bool> deleteUser(int id) async {
    final int deleted = await (delete(users)..where((Users u) => u.id.equals(id))).go();
    return deleted > 0;
  }

  Future<void> clearUsers() => delete(users).go();

  Future<List<User>> getAllUsers() => select(users).get();
}

LazyDatabase _openConnection() => LazyDatabase(() async {
  final Directory dbFolder = await getApplicationDocumentsDirectory();
  final File file = File(p.join(dbFolder.path, 'app.db'));
  return NativeDatabase(file);
});

