import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  // init sqflite
  WidgetsFlutterBinding.ensureInitialized();
  // databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//define a billing object, field contains type(income or expense), amount, date, description and kind of payment
// type use enum, enum give number to each type, income is 0, expense is 1
enum BillingType {
  income,
  expense,
}

class Billing {
  Billing(
      {required this.type,
      required this.amount,
      required this.date,
      required this.description,
      required this.payment});

  final BillingType type;
  final int amount;
  final DateTime date;
  final String description;
  final String payment;
}

class _MyHomePageState extends State<MyHomePage> {

  //define a list of billing objects
  final List<Billing> _billings = <Billing>[];

  //define database
  late final Future<Database> database;

  //define add function to get data from sqllite and add to the list
  Future<void> _loadBillings() async {
    // Open the database and store the reference.
    database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'billing_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
            'CREATE TABLE Billing (id INTEGER PRIMARY KEY, type INTEGER, amount INTEGER, date TEXT, description TEXT, payment TEXT)');
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
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
    db.query('Billing').then((value) {
      for (var item in value) {
        _billings.add(Billing(
            type: item['type'] == 0 ? BillingType.income : BillingType.expense,
            amount: item['amount'] as int,
            date: DateTime.parse(item['date'] as String),
            description: item['description'] as String,
            payment: item['payment'] as String));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadBillings();
  }

  Future<void> _incrementCounter() async {
    final db = await database;
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
    // reload the list
    _billings.clear();
    await db.query('Billing').then((value) {
      for (var item in value) {
        _billings.add(Billing(
            type: item['type'] == 0 ? BillingType.income : BillingType.expense,
            amount: item['amount'] as int,
            date: DateTime.parse(item['date'] as String),
            description: item['description'] as String,
            payment: item['payment'] as String));
      }
    });
    // var res = await db.delete('Billing', where: 'id != 0');
    // log('delete $res');
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // add a list view, source is _billings
            Expanded(
              child: ListView.builder(
                itemCount: _billings.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(_billings[index].description),
                    subtitle: Text(_billings[index].amount.toString()),
                    leading: Icon(_billings[index].type == BillingType.income
                        ? Icons.add
                        : Icons.remove),
                    trailing: Text(_billings[index].payment),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
