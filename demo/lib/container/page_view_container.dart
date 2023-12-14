import 'dart:async';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    var appLocalizations = AppLocalizations.of(context)!;

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
                tooltip: appLocalizations.addBilling,
                shape: const CircleBorder(),
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: const Icon(Icons.add),
              ),
        bottomNavigationBar: Container(
          color: Colors.transparent,
          height: Platform.isIOS ? kBottomNavigationBarHeight * 3 / 2 : kBottomNavigationBarHeight * 6 / 5,
          child: BottomAppBar(
            padding: EdgeInsets.zero,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                buildBottomAppBarItem(() {
                  animateToPage(0);
                }, Icons.menu, _getCurrentColor(0), appLocalizations.home),
                buildBottomAppBarItem(() {
                  animateToPage(1);
                }, Icons.bar_chart, _getCurrentColor(1), appLocalizations.chart),
                Container(
                  width: 48,
                ),
                buildBottomAppBarItem(() {
                  animateToPage(2);
                }, Icons.search, _getCurrentColor(2), appLocalizations.search),
                buildBottomAppBarItem(() {
                  animateToPage(3);
                }, Icons.settings, _getCurrentColor(3), appLocalizations.setting),
              ],
            ),
          ),
        ));
  }

  void animateToPage(int pageIndex) {
    _pageController.animateToPage(pageIndex, duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
  }

  InkWell buildBottomAppBarItem(Null Function() tapFunction, IconData itemIcon, Color itemColor, String itemName) {
    return InkWell(
      onTap: tapFunction,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: SizedBox(
        width: 48,
        child: Center(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  itemIcon,
                  color: itemColor,
                  size: 24,
                ),
                Text(
                  itemName,
                  style: TextStyle(fontSize: 12, color: itemColor),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  Color _getCurrentColor(page) => currentPage == page ? Colors.pink : Colors.white;

  void _goToBillingDetailPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BillingDetailPage()));
  }

  Future<List<Billing>> _loadBillingData() async {
    var list = await GetIt.I<BillingRepository>().billings();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
}
