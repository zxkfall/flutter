import 'provider/billing_provider.dart';
import 'package:demo/repository/billing_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'page/billing_detail_page.dart';
import 'package:provider/provider.dart';

import 'page/home_page.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
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
