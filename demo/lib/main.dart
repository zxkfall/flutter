import 'package:demo/billing.dart';
import 'package:demo/billing_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'billing_detail_page.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';

Future<void> main() async {
  GetIt.I.registerSingleton<BillingRepository>(SqlBillingRepository());
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => BillingProvider()),
    ],
    child: const MyApp(),
  ));
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
        home: const HomePage(),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => const HomePage(),
          '/billing-detail': (BuildContext context) => const BillingDetailPage(
                billing: null,
              ),
        });
  }
}

class BillingProvider with ChangeNotifier {
  List<Billing> _billings = <Billing>[];

  List<Billing> get billings => _billings;

  void setBillings(List<Billing> newBillings) {
    _billings = newBillings;
    notifyListeners(); // 通知监听器数据已更新
  }
}
