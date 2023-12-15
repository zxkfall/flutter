import 'dart:io';
import 'dart:developer' as developer;

import 'package:demo/page/sub_setting_page/change_theme_page.dart';
import 'package:demo/page/sub_setting_page/index_images_setting_page.dart';
import 'package:demo/view/top_bar_placeholder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:decimal/decimal.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    var billingProvider = Provider.of<BillingProvider>(context, listen: false);
    var appLocalizations = AppLocalizations.of(context)!;
    return Column(children: <Widget>[
      const TopBarPlaceholder(),
      buildSettingOption(
          () => {
                importExcel(context).then((value) {
                  Utils.showToast(
                      value != 0
                          ? appLocalizations.importSuccessTotalImportWhatRecords(value)
                          : appLocalizations.noDataImported,
                      context);
                })
              },
          context,
          appLocalizations.importDataCompatibleOldApp),
      buildSettingOption(() => {buildConfirmClearDialog(context, billingProvider)}, context,
          appLocalizations.clearDataWillClearAllRecords),
      buildSettingOption(
          () => {
                exportExcel().then((value) {
                  Utils.showToast(
                      appLocalizations.exportSuccessfulTotalWhatRecords(int.parse(value['count']!)), context);
                })
              },
          context,
          appLocalizations.exportData),
      buildSettingOption(
          () => {
                shareExcel().then((value) {
                  Utils.showToast(appLocalizations.sharingSuccessfulTotalWhatExported(value), context);
                })
              },
          context,
          appLocalizations.sharingData),
      buildSettingOption(
          () => {
                Future.delayed(const Duration(milliseconds: 150), () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const IndexImagesSettingPage(),
                  ));
                })
              },
          context,
          appLocalizations.indexImagesSetting),
      buildSettingOption(() => {Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangeThemePage()))},
          context, appLocalizations.changeTheme),
    ]);
  }

  SizedBox buildSettingOption(Set<void> Function() changeThemePressEvent, BuildContext context, String innerText) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: changeThemePressEvent,
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            side: BorderSide(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1), width: 1)),
        child: Row(
          children: [
            Text(
              innerText,
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            )
          ],
        ),
      ),
    );
  }

  void buildConfirmClearDialog(BuildContext context, BillingProvider billingProvider) {
    var appLocalizations = AppLocalizations.of(context)!;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(appLocalizations.clearData),
            content: Text(appLocalizations.areYouSureYouWantToClearAllRecords),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(appLocalizations.cancel)),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    GetIt.I<BillingRepository>().clearBilling().then((value) {
                      Utils.showToast(appLocalizations.clearSuccessfulTotalWhatRecords(value), context);
                      billingProvider.setBillings(<Billing>[]);
                    });
                  },
                  child: Text(appLocalizations.confirm)),
            ],
          );
        });
  }

  Future<Map<String, String>> exportExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow([
      const TextCellValue('Date'),
      const TextCellValue('Amount'),
      const TextCellValue('Type'),
      const TextCellValue('Kind'),
      const TextCellValue('Description')
    ]);
    var billings = await GetIt.I<BillingRepository>().billings();
    for (var billing in billings) {
      sheetObject.appendRow([
        TextCellValue(billing.date.toString()),
        TextCellValue(billing.amount.toString()),
        TextCellValue(billing.type == BillingType.expense ? 'COST' : 'INCOME'),
        TextCellValue(billing.kind.name),
        TextCellValue(billing.description)
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
    developer.log('save: $path');
    var file = File(join('$path/billingsInfo-${DateFormat('yyyy-MM-dd-HH-mm-ss').format(DateTime.now())}.xlsx'))
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);
    if (Platform.isIOS) {
      final result = await Share.shareXFiles([XFile(file.path)], text: 'Excel Data');
      if (result.status == ShareResultStatus.success) {
        developer.log('Thank you for sharing the Excel!');
      }
    }
    developer.log(file.path);
    var res = <String, String>{'path': Platform.isIOS ? '' : file.path, 'count': billings.length.toString()};
    return res;
  }

  Future<int> shareExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow([
      const TextCellValue('Date'),
      const TextCellValue('Amount'),
      const TextCellValue('Type'),
      const TextCellValue('Kind'),
      const TextCellValue('Description')
    ]);
    var billings = await GetIt.I<BillingRepository>().billings();
    for (var billing in billings) {
      sheetObject.appendRow([
        TextCellValue(billing.date.toString()),
        TextCellValue(billing.amount.toString()),
        TextCellValue(billing.type == BillingType.expense ? 'COST' : 'INCOME'),
        TextCellValue(billing.kind.name),
        TextCellValue(billing.description)
      ]);
    }
    var fileBytes = excel.save();
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    var tempDirectory = await getApplicationCacheDirectory();
    developer.log('temp path: ${tempDirectory.path}');
    var file = File(
        join('${tempDirectory.path}/billingsInfo-${DateFormat('yyyy-MM-dd-HH-mm-ss').format(DateTime.now())}.xlsx'))
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    final result = await Share.shareXFiles([XFile(file.path)], text: 'Excel Data');

    if (result.status == ShareResultStatus.success) {
      developer.log('Thank you for sharing the Excel!');
    }
    return billings.length;
  }

  Future<int> importExcel(BuildContext context) async {
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
          var billingType = element[2]!.value.toString() == 'COST' ? BillingType.expense : BillingType.income;
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
                                      : element[3]!.value.toString() == 'Tobacco & wine'
                                          ? 'tobaccoAndWine'
                                          : element[3]!.value.toString() == 'Sports'
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
