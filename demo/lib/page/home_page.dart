import 'dart:async';
import 'dart:io';
import 'package:demo/page/billing_detail_page.dart';
import 'package:demo/page/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../model/billing.dart';
import '../view/billing_list_view.dart';
import '../repository/billing_repository.dart';
import '../provider/billing_provider.dart';
import 'chart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBillingData().then((value) {
        Provider.of<BillingProvider>(context, listen: false).setBillings(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        body: PageView(
          controller: _pageController,
          children: const <Widget>[
            // 展示页面
            BillingListView(),
            // 图表页面
            ChartPage(),
            // 设置页面
            SettingPage(),
          ],
        ),
        resizeToAvoidBottomInset: true,
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: MediaQuery.of(context).viewInsets.bottom != 0
            ? null
            : FloatingActionButton(
                onPressed: () {
                  _goToBillingDetailPage(context);
                },
                tooltip: 'Add Billing',
                shape: const CircleBorder(),
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: const Icon(Icons.add),
              ),
        bottomNavigationBar: SizedBox(
          height: Platform.isIOS
              ? kBottomNavigationBarHeight * 3 / 2
              : kBottomNavigationBarHeight * 6 / 5,
          child: BottomAppBar(
            padding: const EdgeInsets.only(left: 30, right: 30),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 32,
                            width: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _pageController.animateToPage(0,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut);
                              },
                              icon: const Icon(Icons.menu),
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Home',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 48),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 32,
                              width: 32,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  _pageController.animateToPage(1,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut);
                                },
                                icon: const Icon(Icons.bar_chart),
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Chart',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 32,
                            width: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _pageController.animateToPage(1,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut);
                              },
                              icon: const Icon(Icons.settings),
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Setting',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  void _goToBillingDetailPage(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const BillingDetailPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  Future<List<Billing>> _loadBillingData() async {
    var list = await GetIt.I<BillingRepository>().billings();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
}
