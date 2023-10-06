// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:demo/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
  // Help me add a new test to test that all the billing data in the sqllite can be rendered into the listview
  testWidgets('Test that all the billing data in the sqllite',
      (WidgetTester tester) async {
    // init sqllite
    // Avoid errors caused by flutter upgrade.
// Importing 'package:flutter/widgets.dart' is required.
    WidgetsFlutterBinding.ensureInitialized();
// Open the database and store the reference.
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'billing_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
            'CREATE TABLE Billing (id INTEGER PRIMARY KEY, type INTEGER, amount REAL, date TEXT, description TEXT, payment TEXT)');
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    // Insert some fake data into the table.
    await database.then((db) => db.insert(
        'Billing',
        {
          'type': 0,
          'amount': 100,
          'date': DateTime.now().toString(),
          'description': 'fake income',
          'payment': 'cash'
        },
        conflictAlgorithm: ConflictAlgorithm.replace));
    await database.then((db) => db.insert(
        'Billing',
        {
          'type': 1,
          'amount': 200,
          'date': DateTime.now().toString(),
          'description': 'fake expense',
          'payment': 'credit card'
        },
        conflictAlgorithm: ConflictAlgorithm.replace));
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    // assert that the listview contains the fake data, assert all fields
    expect(find.text('fake income'), findsOneWidget);
    expect(find.text('fake expense'), findsOneWidget);
    expect(find.text('100'), findsNWidgets(2));
    expect(find.text('cash'), findsNWidgets(2));
    expect(find.text('credit card'), findsNWidgets(2));
  });
}
