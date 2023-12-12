import 'package:demo/provider/theme_provider.dart';

import 'provider/billing_provider.dart';
import 'package:demo/repository/billing_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'page/billing_detail_page.dart';
import 'package:provider/provider.dart';

import 'container/page_view_container.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: ThemeProvider())],
      child: Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
        return MaterialApp(
            title: 'Maple Billing',
            theme: ThemeData(
              colorScheme:
                  ColorScheme.fromSeed(seedColor: themeProvider.primaryColor),
              useMaterial3: true,
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PageViewContainer(),
            routes: <String, WidgetBuilder>{
              '/home': (BuildContext context) => const PageViewContainer(),
              '/billing-detail': (BuildContext context) =>
                  const BillingDetailPage(
                    billing: null,
                  ),
            });
      }),
    );
  }
}
