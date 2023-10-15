import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:decimal/decimal.dart';
import 'package:get_it/get_it.dart';

import 'billing.dart';
import 'billing_repository.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(children: <Widget>[
        const Text('Settings Page'),
        TextButton(
            onPressed: () => {
                  openFilePickerAndRead().then((value) => {
                        // _showToast('导入成功，共导入$value条数据')
                      })
                },
            child: const Text('选择文件')),
        TextButton(
            onPressed: () => {GetIt.I<BillingRepository>().clearBilling()},
            child: const Text('清除数据'))
      ]),
    );
  }

  Future<int> openFilePickerAndRead() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, // 文件类型
        allowedExtensions: ['xlsx'],
        withData: true,
        withReadStream: true // 允许的文件扩展名
        );
    if (result != null) {
      Uint8List bytes = result.files.single.bytes!;

      final excel = Excel.decodeBytes(bytes);

      List<Billing> billings = [];
      for (var table in excel.tables.keys) {
        for (var element in excel.tables[table]!.rows) {
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
                  billingType, element[3]!.value.toString()),
              description: '${element[3]!.value} ${element[4]!.value}');
          billings.add(billing);
        }
      }

      await GetIt.I<BillingRepository>().batchInsertBilling(billings);
      return excel.tables[0]!.maxRows;
    }
    // 用户取消了文件选择
    return 0;
  }
}
