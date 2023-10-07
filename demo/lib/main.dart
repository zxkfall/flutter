import 'package:demo/billing_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'billing.dart';
import 'billing_detail_page.dart';

Future<void> main() async {
  GetIt.I.registerSingleton<BillingRepository>(SqlBillingRepository());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Maple Billing',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
        routes: <String, WidgetBuilder>{
          '/billing-detail': (BuildContext context) => const BillingDetailPage(
                billing: null,
              ),
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
                      trailing: Text(_billings[index].kind.name),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/billing-detail');
        },
        tooltip: 'Add Billing',
        child: const Icon(Icons.add),
      ),
    );
  }
}
