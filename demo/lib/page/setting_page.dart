import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:decimal/decimal.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../model/billing.dart';
import '../repository/billing_repository.dart';
import '../provider/billing_provider.dart';
import '../utils/utils.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    FToast fToast = FToast();
    fToast.init(context);
    var billingProvider = Provider.of<BillingProvider>(context, listen: false);
    return Center(
      child: Column(children: <Widget>[
        const Text('Settings Page'),
        Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                  onPressed: () => {
                        openFilePickerAndRead(context).then((value) {
                          Utils.showToast('导入成功，共导入$value条数据', fToast);
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
        )
      ]),
    );
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
