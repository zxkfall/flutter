import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:demo/page/billing_detail_page.dart';
import 'package:demo/page/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../model/billing.dart';
import '../page/billing_list_page.dart';
import '../repository/billing_repository.dart';
import '../provider/billing_provider.dart';
import '../page/chart_page.dart';
import '../page/search_page.dart';

class PageViewContainer extends StatefulWidget {
  const PageViewContainer({super.key});

  @override
  State<PageViewContainer> createState() => _PageViewContainerState();
}

class _PageViewContainerState extends State<PageViewContainer> {
  final PageController _pageController = PageController(initialPage: 0);
  var currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBillingData().then((value) {
        Provider.of<BillingProvider>(context, listen: false).setBillings(value);
      });
    });
    _pageController.addListener(() {
      currentPage = _pageController.page!.round();
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          toolbarHeight: 0,
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: const <Widget>[
            BillingListPage(),
            ChartPage(),
            SearchPage(),
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
                    InkWell(
                      onTap: () {
                        _pageController.animateToPage(0,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeInOut);
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 32,
                              width: 32,
                              child: Icon(
                                Icons.menu,
                                color: _getCurrentColor(0),
                              ),
                            ),
                            Text(
                              'Home',
                              style: TextStyle(
                                  fontSize: 12, color: _getCurrentColor(0)),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 48),
                      child: InkWell(
                        onTap: () {
                          _pageController.animateToPage(1,
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeInOut);
                        },
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 32,
                                width: 32,
                                child: Icon(
                                  Icons.bar_chart,
                                  color: _getCurrentColor(1),
                                ),
                              ),
                              Text(
                                'Chart',
                                style: TextStyle(
                                    fontSize: 12, color: _getCurrentColor(1)),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 36),
                      child: InkWell(
                        onTap: () {
                          _pageController.animateToPage(2,
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeInOut);
                        },
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  height: 32,
                                  width: 32,
                                  child: Icon(
                                    Icons.search,
                                    color: _getCurrentColor(2),
                                  )),
                              Text(
                                'Search',
                                style: TextStyle(
                                    fontSize: 12, color: _getCurrentColor(2)),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _pageController.animateToPage(3,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeInOut);
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 32,
                              width: 32,
                              child: Icon(
                                Icons.settings,
                                color: _getCurrentColor(3),
                              ),
                            ),
                            Text(
                              'Setting',
                              style: TextStyle(
                                  fontSize: 12, color: _getCurrentColor(3)),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    log('disposed');
  }

  Color _getCurrentColor(page) =>
      currentPage == page ? Colors.pink : Colors.white;

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
