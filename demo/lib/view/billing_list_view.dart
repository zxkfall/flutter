import 'dart:math';

import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

import '../model/billing.dart';
import '../page/billing_detail_page.dart';
import '../provider/billing_provider.dart';
import '../repository/billing_repository.dart';
import '../utils/utils.dart';

class BillingListView extends StatefulWidget {
  const BillingListView({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _BillingListViewState();
  }
}

class _BillingListViewState extends State<BillingListView> {
  var imgUrls = [
    'https://proxy.pixivel.moe/c/540x540_70/img-master/img/2022/11/18/00/00/10/102875400_p0_master1200.jpg',
    'https://proxy.pixivel.moe/c/540x540_70/img-master/img/2018/11/17/19/41/38/71696037_p0_master1200.jpg',
    'https://proxy.pixivel.moe/c/540x540_70/img-master/img/2021/05/27/00/00/05/90117491_p0_master1200.jpg',
    'https://proxy.pixivel.moe/c/540x540_70/img-master/img/2017/05/12/00/18/08/62854438_p0_master1200.jpg',
    'https://proxy.pixivel.moe/c/540x540_70/img-master/img/2021/01/11/00/04/49/86966041_p0_master1200.jpg',
  ];
  var color = Colors.white;
  var image = Image.memory(Uint8List(0));
  @override
  void initState() {
    super.initState();
    loadImage();
    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      if (info.sizeBytes > 0) {
        getImageMainColor(info.image.width.toDouble(),
            info.image.height.toDouble(), image.image)
            .then((value) {
          var computeLuminance =
          value.dominantColor!.color.computeLuminance();
          color = computeLuminance > 0.5 ? Colors.black : Colors.white;
          setState(() {});
        });
      }
    }));
  }

  Future<void> loadImage() async {
    image = Image.network(
      imgUrls[Random().nextInt(imgUrls.length)],
      width: double.infinity,
      height: null,
      fit: BoxFit.contain,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        var totalBytes = loadingProgress.expectedTotalBytes;
        var bytesLoaded = loadingProgress.cumulativeBytesLoaded;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(64.0),
            child: CircularProgressIndicator(
              value: totalBytes != null ? bytesLoaded / totalBytes : null,
            ),
          )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingProvider>(
      builder: (context, billingProvider, child) {
        final billings = billingProvider.billings;
        return ListView.builder(
          itemCount: billings.length,
          itemBuilder: (BuildContext context, int index) {
            final currentBilling = billings[index];
            final previousBilling = index > 0 ? billings[index - 1] : null;
            final showDateHeader = previousBilling == null ||
                !Utils.isSameDay(currentBilling.date, previousBilling.date);

            final dailyTotalMap =
            Utils.calculateDailyTotal(currentBilling.date, billings);

            var hasIncome = dailyTotalMap['income'] != Decimal.zero;
            var hasExpense = dailyTotalMap['expense'] != Decimal.zero;

            var incomeAmount =
            !hasIncome ? '' : '+\$${dailyTotalMap['income']}';
            var spaceAndComma = hasIncome && hasExpense ? ', ' : '';
            var expenseAmount =
            !hasExpense ? '' : '-\$${dailyTotalMap['expense']}';
            var formattedAmount = currentBilling.amount.toStringAsFixed(2);
            var amountPrefix =
            currentBilling.type == BillingType.income ? '+' : '-';
            var totalExpense = billings.fold(
                Decimal.zero,
                    (previousValue, element) =>
                previousValue +
                    (element.type == BillingType.expense
                        ? element.amount
                        : Decimal.zero));
            var totalIncome = billings.fold(
                Decimal.zero,
                    (previousValue, element) =>
                previousValue +
                    (element.type == BillingType.income
                        ? element.amount
                        : Decimal.zero));



            return Column(
              children: <Widget>[
                if (showDateHeader)
                  Column(
                    children: [
                      if (index == 0)
                        Stack(
                          children: [
                            image,
                            Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    'total expense: $totalExpense, total income: $totalIncome',
                                    style: TextStyle(fontSize: 16,color: color),
                                  ),
                                )),
                          ],
                        ),
                      ListTile(
                        dense: true,
                        title: Text(
                          DateFormat.yMMMd().format(currentBilling.date),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          'Total: $incomeAmount$spaceAndComma$expenseAmount',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                Dismissible(
                  key: Key(currentBilling.id.toString()),
                  onDismissed: (direction) {
                    _removeBilling(context, index);
                  },
                  background: Container(
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        Future.delayed(const Duration(milliseconds: 150), () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  BillingDetailPage(billing: currentBilling),
                            ),
                          );
                        });
                      },
                      highlightColor: Colors.transparent,
                      child: ListTile(
                        dense: true,
                        title: Text(currentBilling.kind.name),
                        subtitle: Text(currentBilling.description),
                        leading: Icon(
                          BillingIconMapper.getIcon(
                              currentBilling.type, currentBilling.kind),
                        ),
                        trailing: Text(
                          '$amountPrefix\$$formattedAmount',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<PaletteGenerator> getImageMainColor(
      double imageWidth, double imageHeight, ImageProvider<Object> image) async {
    var rect = Rect.fromCenter(
        center: Offset(imageWidth / 2, imageHeight / 2),
        width: imageWidth,
        height: imageHeight);
    var color = await PaletteGenerator.fromImageProvider(
      image,
      region: rect,
      size: Size(imageWidth, imageHeight),
    );
    return color;
  }

  Future<void> _removeBilling(BuildContext context, int index) async {
    final billingProvider =
    Provider.of<BillingProvider>(context, listen: false);

    final billing = billingProvider.billings[index];
    await GetIt.I<BillingRepository>().deleteBilling(billing.id);

    final updatedBillings = await GetIt.I<BillingRepository>().billings();
    billingProvider.setBillings(updatedBillings);
  }
}
