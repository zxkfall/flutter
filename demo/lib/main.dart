import 'package:demo/billing_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'billing.dart';

Future<void> main() async {
  GetIt.I.registerSingleton<BillingRepository>(BillingRepository());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(
        title: 'Flutter Demo Home Page',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Billing> _billings = <Billing>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadBillingData();
    });
  }

  Future<void> loadBillingData() async {
    _billings.clear();
    var list = await GetIt.I<BillingRepository>().billings();
    _billings.addAll(list);

    setState(() {
      // 更新 UI 或执行其他操作
    });
  }


  Future<void> _insertBilling() async {
    await GetIt.I<BillingRepository>().insertBilling(Billing(
        id: 1,
        type: BillingType.income,
        amount: 100,
        date: DateTime.now(),
        description: 'fake income',
        payment: 'cash'));
    _billings.clear();
    await GetIt.I<BillingRepository>()
        .billings()
        .then((value) => _billings.addAll(value));
    setState(() {});
  }

  Future<void> removeBilling(int index) async {
    await GetIt.I<BillingRepository>().deleteBilling(_billings[index].id);
    setState(() {
      _billings.removeAt(index);
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // add a list view, source is _billings
            Expanded(
              child: ListView.builder(
                itemCount: _billings.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    key: Key(_billings[index].id.toString()),
                    // 使用每个项目的唯一标识符作为 key
                    onDismissed: (direction) {
                      // 在项目被滑动删除时执行的操作
                      removeBilling(index);
                    },
                    background: Container(
                      color: Colors.red, // 定义滑动时显示的背景颜色
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      title: Text(_billings[index].description),
                      subtitle: Text(_billings[index].amount.toString()),
                      leading: Icon(_billings[index].type == BillingType.income
                          ? Icons.add
                          : Icons.remove),
                      trailing: Text(_billings[index].payment),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _insertBilling,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
