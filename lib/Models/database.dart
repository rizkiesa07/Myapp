import 'package:drift/drift.dart';

import 'dart:io';
import 'package:drift/native.dart';
import 'package:siAbank/Models/transaction_with_category.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';


part 'database.g.dart';

@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 128)();
  IntColumn get type => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 128)();
  IntColumn get category_id => integer()();
  DateTimeColumn get transaction_date => dateTime()();
  IntColumn get amount => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DriftDatabase(tables: [Categories, Transactions])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;
  Future<List<Category>> getAllCategoryRepo(int type) async {
    return await (select(categories)..where((tbl) => tbl.type.equals(type)))
        .get();
  }

  Future updateCategoryRepo(int id, String newName) async {
    return (update(categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(newName),
      ),
    );
  }

  Future updateTransactionRepo(int id, int amount, int categoryId,
      DateTime transactionDate, String nameDetail) async {
    return (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
          name: Value(nameDetail),
          amount: Value(amount),
          category_id: Value(categoryId),
          transaction_date: Value(transactionDate)),
    );
  }

  Future deleteCategoryRepo(int id) async {
    return (delete(categories)..where((t) => t.id.equals(id))).go();
  }

  Future deleteTrabsactionRepo(int id) async {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }
Future<int> sumIncome() async {
  try {
    final sumQuery = await customSelect(
        'SELECT SUM(a.amount) as total FROM transactions AS a INNER JOIN categories AS b ON a.category_id = b.id WHERE b.type = 1');

    // Get the result as a list
    final results = await sumQuery.get(); 

    // Check if the result list is empty
    if (results.isEmpty) {
      return 0; // Return 0 if no data
    } else {
      // Extract the 'total' value from the first row
      return results.first.read<int>('total'); 
    }

  } catch (e) {
    print('Error calculating sumIncome: $e');
    return 0; 
  }
}


  Future<int> sumExpense() async {
  try {
    final sumQuery = await customSelect(
        'SELECT SUM(a.amount) as total FROM transactions AS a INNER JOIN categories AS b ON a.category_id = b.id WHERE b.type = 2');

    // Get the result as a list
    final results = await sumQuery.get(); 

    // Check if the result list is empty
    if (results.isEmpty) {
      return 0; // Return 0 if no data
    } else {
      // Extract the 'total' value from the first row
      return results.first.read<int>('total'); 
    }

  } catch (e) {
    print('Error calculating sumIncome: $e');
    return 0; 
  }
}


  Stream<List<TransactionWithCategory>> getTransactionByDateRepo(
      DateTime date) {
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id))
    ])
      ..where(transactions.transaction_date.equals(date)));
    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
            row.readTable(transactions), row.readTable(categories));
      }).toList();
    });
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;
    // We can't access /tmp on Android, which sqlite3 would try by default.
    // Explicitly tell it about the correct temporary directory.
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
