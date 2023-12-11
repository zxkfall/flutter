import 'dart:developer';
import 'dart:io';

import 'package:demo/page/index_images_setting_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:decimal/decimal.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../model/billing.dart';
import '../repository/billing_repository.dart';
import '../provider/billing_provider.dart';
import '../utils/utils.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    FToast fToast = FToast();
    fToast.init(context);
    var billingProvider = Provider.of<BillingProvider>(context, listen: false);
    return ListView(
      children: [
        Column(children: <Widget>[
          Container(
            height: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => {
                openFilePickerAndRead(context).then((value) {
                  Utils.showToast(
                      value != 0 ? '导入成功，共导入$value条数据' : '未导入数据', fToast);
                })
              },
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  side: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.1),
                      width: 1)),
              child: const Row(
                children: [
                  Text(
                    '导入数据',
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {
                  buildConfirmClearDialog(context, fToast, billingProvider);
                },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.1),
                        width: 1)),
                child: const Row(
                  children: [
                    Text(
                      '清除数据(！！！将会清除所有数据)',
                      style: TextStyle(fontSize: 16),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    )
                  ],
                )),
          ),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () => {
                      exportExcel().then((value) {
                        Utils.showToast('导出成功，共导出$value条数据', fToast);
                      })
                    },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.1),
                        width: 1)),
                child: const Row(
                  children: [
                    Text(
                      '导出数据',
                      style: TextStyle(fontSize: 16),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    )
                  ],
                )),
          ),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () => {
                      shareExcel().then((value) {
                        Utils.showToast('分享成功，共导出$value条数据', fToast);
                      })
                    },
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.1),
                        width: 1)),
                child: const Row(
                  children: [
                    Text(
                      '分享数据',
                      style: TextStyle(fontSize: 16),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    )
                  ],
                )),
          ),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => {
                Future.delayed(const Duration(milliseconds: 150), () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const IndexImagesSettingPage(),
                  ));
                })
              },
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  side: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.1),
                      width: 1)),
              child: const Row(
                children: [
                  Text(
                    '首页图片设置',
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  )
                ],
              ),
            ),
          )
        ]),
      ],
    );
  }

  void buildConfirmClearDialog(
      BuildContext context, FToast fToast, BillingProvider billingProvider) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('清除数据'),
            content: const Text('确定要清除所有数据吗？'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    GetIt.I<BillingRepository>().clearBilling().then((value) {
                      Utils.showToast('清除成功，共清除$value条数据', fToast);
                      billingProvider.setBillings(<Billing>[]);
                    });
                  },
                  child: const Text('确定')),
            ],
          );
        });
  }

  Future<Map<String, String>> exportExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow(['Date', 'Amount', 'Type', 'Kind', 'Description']);
    var billings = await GetIt.I<BillingRepository>().billings();
    for (var billing in billings) {
      sheetObject.appendRow([
        billing.date.toString(),
        billing.amount,
        billing.type == BillingType.expense ? 'COST' : 'INCOME',
        billing.kind.name,
        billing.description
      ]);
    }
    var fileBytes = excel.save();
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    var path = '';
    if (Platform.isAndroid) {
      var directory = await getDownloadsDirectory();
      path = '${directory!.path.split('Android')[0]}Download';
    } else if (Platform.isIOS) {
      var directory = await getApplicationCacheDirectory();
      path = directory.path;
    }
    log('save: $path');
    var file = File(join(
        '$path/billingsInfo-${DateFormat('yyyy-MM-dd-HH-mm-ss').format(DateTime.now())}.xlsx'))
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);
    if (Platform.isIOS) {
      final result =
          await Share.shareXFiles([XFile(file.path)], text: 'Excel Data');
      if (result.status == ShareResultStatus.success) {
        log('Thank you for sharing the Excel!');
      }
    }
    log(file.path);
    var res = <String, String>{
      'path': Platform.isIOS ? '' : file.path,
      'count': billings.length.toString()
    };
    return res;
  }

  Future<int> shareExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow(['Date', 'Amount', 'Type', 'Kind', 'Description']);
    var billings = await GetIt.I<BillingRepository>().billings();
    for (var billing in billings) {
      sheetObject.appendRow([
        billing.date.toString(),
        billing.amount,
        billing.type == BillingType.expense ? 'COST' : 'INCOME',
        billing.kind.name,
        billing.description
      ]);
    }
    var fileBytes = excel.save();
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    var tempDirectory = await getApplicationCacheDirectory();
    log('temp path: ${tempDirectory.path}');
    var file = File(join(
        '${tempDirectory.path}/billingsInfo-${DateFormat('yyyy-MM-dd-HH-mm-ss').format(DateTime.now())}.xlsx'))
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    final result =
        await Share.shareXFiles([XFile(file.path)], text: 'Excel Data');

    if (result.status == ShareResultStatus.success) {
      log('Thank you for sharing the Excel!');
    }
    return billings.length;
  }

  Future<int> openFilePickerAndRead(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, // 文件类型
        allowedExtensions: ['xlsx'],
        withData: true,
        withReadStream: true // 允许的文件扩展名
        );
    if (result != null) {
      Uint8List bytes = result.files.single.bytes!;

      final excel = Excel.decodeBytes(bytes);

      var totalRows = 0;
      List<Billing> billings = [];
      var tables = excel.tables;
      for (var table in tables.keys) {
        totalRows += tables[table]!.maxRows;
        for (var element in tables[table]!.rows) {
          if (element[0]!.value.toString() == 'Date') {
            continue;
          }
          var billingType = element[2]!.value.toString() == 'COST'
              ? BillingType.expense
              : BillingType.income;
          var billing = Billing(
              id: 0,
              date: DateTime.parse(element[0]!.value.toString()),
              amount: Decimal.parse(element[1]!.value.toString()),
              type: billingType,
              kind: stringToBillingKind(
                  billingType,
                  element[3]!.value.toString() == 'Study'
                      ? 'education'
                      : element[3]!.value.toString() == 'Makeups'
                          ? 'cosmetics'
                          : element[3]!.value.toString() == 'Snacks'
                              ? 'snack'
                              : element[3]!.value.toString() == 'Hydropower'
                                  ? 'waterAndElectricity'
                                  : element[3]!.value.toString() == 'Clothes'
                                      ? 'apparel'
                                      : element[3]!.value.toString() ==
                                              'Tobacco & wine'
                                          ? 'tobaccoAndWine'
                                          : element[3]!.value.toString() ==
                                                  'Sports'
                                              ? 'sport'
                                              : element[3]!.value.toString()),
              description: '${element[3]!.value} ${element[4]!.value}');
          billings.add(billing);
        }
      }

      await GetIt.I<BillingRepository>().batchInsertBilling(billings);
      await GetIt.I<BillingRepository>().billings().then((value) {
        Provider.of<BillingProvider>(context, listen: false).setBillings(value);
      });
      return totalRows;
    }
    // 用户取消了文件选择
    return 0;
  }
}
