import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:demo/billing_detail_page.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:get_it/get_it.dart';
import 'billing.dart';
import 'billing_list_view.dart';
import 'billing_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Billing> _billings = <Billing>[];
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBillingData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: PageView(
          controller: _pageController,
          children: <Widget>[
            // 展示页面
            BillingListView(billings: _billings, removeBilling: _removeBilling),
            // 设置页面
            Center(
              child: Row(
                  children: <Widget>[
                  Text('Settings Page'),
                    TextButton(onPressed: ()=>{
                      openFilePickerAndRead()
                    }, child: const Text('选择文件')),
                  ]),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _goToBillingDetailPage(context);
          },
          tooltip: 'Add Billing',
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: SizedBox(
          height: 64,
          child: BottomAppBar(
            padding: const EdgeInsets.only(top: 0.0, left: 14, right: 14),
            color: Theme.of(context).colorScheme.primary,
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    _pageController.animateToPage(0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut);
                  },
                  icon: const Icon(Icons.menu),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () {
                    _pageController.animateToPage(1,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut);
                  },
                  icon: const Icon(Icons.settings),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> openFilePickerAndRead() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, // 文件类型
      allowedExtensions: ['xlsx'],
      withData: true,
      withReadStream: true// 允许的文件扩展名
    );

    if (result != null) {
      Uint8List bytes = result.files.single.bytes!;

      final excel = Excel.decodeBytes(bytes);

      excel.tables.keys.forEach((element) {
        log(element); //sheet Name
        log(excel.tables[element]!.maxCols.toString()); //max col
        log(excel.tables[element]!.maxRows.toString()); //max row
        for (var table in excel.tables.keys) {
          excel.tables[table]!.rows.forEach((element) {
            log(element.map((e) => e!.value.toString()).join(' '));
          });
        }
      });
    } else {
      // 用户取消了文件选择
    }
  }


  void _goToBillingDetailPage(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const BillingDetailPage(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _loadBillingData() async {
    _billings.clear();
    var list = await GetIt.I<BillingRepository>().billings();
    list.sort((a, b) => b.date.compareTo(a.date));
    _billings.addAll(list);
    setState(() {});
  }

  Future<void> _removeBilling(int index) async {
    await GetIt.I<BillingRepository>().deleteBilling(_billings[index].id);
    setState(() {
      _billings.removeAt(index);
    });
  }
}
