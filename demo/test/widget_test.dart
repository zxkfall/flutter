// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:demo/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([Database, DatabaseFactory, DatabaseExecutor, DatabaseException])
void main() {
  testWidgets('Test that all the billing data in the sqllite',
      (WidgetTester tester) async {
    WidgetsFlutterBinding.ensureInitialized();
    // 设置 databaseFactory 为 databaseFactoryFfi
    databaseFactory = databaseFactoryFfi;

    await tester.runAsync(() async {
      final database = openDatabase(
        join(await getDatabasesPath(), 'billing_database.db'),
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE Billing (id INTEGER PRIMARY KEY, type INTEGER, amount INTEGER, date TEXT, description TEXT, payment TEXT)',
          );
        },
        version: 1,
      );

      final db = await database;
      db.insert(
          'Billing',
          {
            'type': 0,
            'amount': 100,
            'date': DateTime.now().toString(),
            'description': 'fake income',
            'payment': 'cash'
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
      db.insert(
          'Billing',
          {
            'type': 1,
            'amount': 200,
            'date': DateTime.now().toString(),
            'description': 'fake expense',
            'payment': 'credit card'
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
      await tester.pumpWidget(MyApp(database: db));
      expect(find.text('fake income'), findsOneWidget);
      expect(find.text('fake expense'), findsOneWidget);
      expect(find.text('100'), findsNWidgets(2));
      expect(find.text('cash'), findsNWidgets(2));
      expect(find.text('credit card'), findsNWidgets(2));
    });
  });
}
