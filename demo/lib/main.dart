import 'package:demo/provider/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  MySharedPreferences mySharedPreferences = MySharedPreferences();
  await mySharedPreferences.init();
  GetIt.I.registerSingleton<MySharedPreferences>(mySharedPreferences);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => BillingProvider()),
      ChangeNotifierProvider.value(value: ThemeProvider())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeProvider themeProvider;

  @override
  void initState() {
    super.initState();
    Provider.of<ThemeProvider>(context, listen: false).init();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return MaterialApp(
          title: 'Maple Billing',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: themeProvider.themeColor),
            useMaterial3: true,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PageViewContainer(),
          routes: <String, WidgetBuilder>{
            '/home': (BuildContext context) => const PageViewContainer(),
            '/billing-detail': (BuildContext context) => const BillingDetailPage(
                  billing: null,
                ),
          });
    });
  }
}

class MySharedPreferences {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs => _prefs!;
}
