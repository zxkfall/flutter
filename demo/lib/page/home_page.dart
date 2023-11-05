import 'dart:async';
import 'dart:developer';
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
  const HomePage({Key? key}) : super(key: key);

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
        resizeToAvoidBottomInset: false,
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _goToBillingDetailPage(context);
          },
          tooltip: 'Add Billing',
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        bottomNavigationBar: SizedBox(
          height: 64,
          child: BottomAppBar(
            padding: const EdgeInsets.only(top: 0.0, left: 14, right: 14),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        _pageController.animateToPage(0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut);
                      },
                      icon: const Icon(Icons.menu),
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: IconButton(
                        onPressed: () {
                          _pageController.animateToPage(1,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut);
                        },
                        icon: const Icon(Icons.bar_chart),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _pageController.animateToPage(2,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut);
                      },
                      icon: const Icon(Icons.settings),
                      color: Colors.white,
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
