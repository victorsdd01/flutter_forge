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

@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<User?> getUserByEmail(String email) async {
    final query = select(users)..where((u) => u.email.equals(email));
    return await query.getSingleOrNull();
  }

  Future<int> insertUser(UsersCompanion user) async {
    return await into(users).insert(user);
  }

  Future<bool> updateUser(User user) async {
    await (update(users)..where((u) => u.id.equals(user.id))).replace(user);
    return true;
  }

  Future<bool> deleteUser(int id) async {
    final deleted = await (delete(users)..where((u) => u.id.equals(id))).go();
    return deleted > 0;
  }

  Future<void> clearUsers() async {
    await delete(users).go();
  }

  Future<List<User>> getAllUsers() async {
    return await select(users).get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.db'));
    return NativeDatabase(file);
  });
}

