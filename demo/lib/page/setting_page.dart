import 'dart:developer';
import 'dart:io';

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
  var focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadText();
  }

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
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                    onPressed: () => {
                          openFilePickerAndRead(context).then((value) {
                            Utils.showToast(
                                value != 0 ? '导入成功，共导入$value条数据' : '未导入数据',
                                fToast);
                          })
                        },
                    child: const Text('选择文件')),
                TextButton(
                    onPressed: () => {
                          GetIt.I<BillingRepository>()
                              .clearBilling()
                              .then((value) {
                            Utils.showToast('清除成功，共清除$value条数据', fToast);
                            billingProvider.setBillings(<Billing>[]);
                          })
                        },
                    child: const Text('清除数据'))
              ],
            ),
          ),
          TextButton(
              onPressed: () => {
                    exportExcel().then((value) {
                      Utils.showToast(
                          '导出成功，共导出${value['count']}条数据${value['path'] == '' ? '!' : '，文件路径:${value['path']}'}',
                          fToast);
                    })
                  },
              child: const Text('导出数据')),
          TextButton(
              onPressed: () => {
                    shareExcel().then((value) {
                      Utils.showToast('分享成功，共导出$value条数据', fToast);
                    })
                  },
              child: const Text('分享数据')),
        ]),
        ..._urlTags.map((element) {
          return TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: element));
              Utils.showToast('复制成功', fToast);
            },
            onLongPress: () {
              _urlTags.remove(element);
              _saveUrls();
              setState(() {});
            },
            child: Text(element),
          );
        }),
        TextField(
          focusNode: focusNode,
          controller: _textController,
          maxLines: 1,
          decoration: InputDecoration(
            labelText: 'Enter Text',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                  _isKeyboardVisible ? Icons.keyboard_hide : Icons.keyboard),
              onPressed: () {
                setState(() {
                  _isKeyboardVisible = !_isKeyboardVisible;
                  if (_isKeyboardVisible) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  } else {
                    FocusManager.instance.primaryFocus?.requestFocus(focusNode);
                  }
                });
              },
            ),
          ),
          onSubmitted: (value) {
            autoFocus = true;
            if (value.trim() == '') {
              return;
            }
            _urlTags.add(value);
            _textController.text = '';
            _saveUrls();
            setState(() {});
          },
          autofocus: autoFocus,
        )
      ],
    );
  }

  var autoFocus = false;
  List<String> _urlTags = [];
  final TextEditingController _textController = TextEditingController();
  bool _isKeyboardVisible = false;

  Future<void> _loadText() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/saved_text.txt');
      if (file.existsSync()) {
        setState(() {
          _urlTags = file
              .readAsStringSync()
              .trim()
              .split(';')
              .where((element) => element != '')
              .toList();
        });
      }
    } catch (e) {
      log('Failed to load text: $e');
    }
  }

  Future<void> _saveUrls() async {
    final text = _urlTags.join(';');
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/saved_text.txt');
      await file.writeAsString(text);
    } catch (e) {
      log('Failed to save text: $e');
    }
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
