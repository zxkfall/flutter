import 'dart:io';
import 'dart:math';

import 'dart:developer' as developer;

import 'package:decimal/decimal.dart';
import 'package:demo/page/preview_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../model/billing.dart';
import 'billing_detail_page.dart';
import '../provider/billing_provider.dart';
import '../repository/billing_repository.dart';
import '../utils/utils.dart';

class BillingListPage extends StatefulWidget {
  const BillingListPage({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _BillingListPageState();
  }
}

class _BillingListPageState extends State<BillingListPage> {
  var imgUrls = [];
  var color = Colors.white;
  var image = Image.network(
      'https://cdn.pixabay.com/photo/2023/10/27/17/04/dahlia-8345799_1280.jpg');

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImageUrls() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/saved_text.txt');
      if (file.existsSync()) {
        var allUrls = file
            .readAsStringSync()
            .trim()
            .split(';')
            .where((element) => element != '')
            .toList();
        imgUrls = allUrls.isEmpty
            ? [
                'https://cdn.pixabay.com/photo/2023/10/27/17/04/dahlia-8345799_1280.jpg'
              ]
            : allUrls;
      } else {
        imgUrls = [
          'https://cdn.pixabay.com/photo/2023/10/27/17/04/dahlia-8345799_1280.jpg'
        ];
      }
    } catch (e) {
      imgUrls = [
        'https://cdn.pixabay.com/photo/2023/10/27/17/04/dahlia-8345799_1280.jpg'
      ];
    }
  }

  Future<void> _loadImage() async {
    await _loadImageUrls();
    developer.log('$imgUrls');
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
        ));
      },
    );
    setState(() {});
    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      if (info.sizeBytes > 0) {
        getImageMainColor(info.image.width.toDouble(),
                info.image.height.toDouble(), image.image)
            .then((value) {
          var computeLuminance = value.dominantColor!.color.computeLuminance();
          color = computeLuminance > 0.5 ? Colors.black : Colors.white;
          setState(() {});
        });
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingProvider>(
      builder: (context, billingProvider, child) {
        final billings = billingProvider.billings;
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
        if (billings.isEmpty) {
          return ListView(
            children: [
              buildHeader(totalExpense, totalIncome),
              const Center(
                child: Text('No billing yet'),
              ),
            ],
          );
        }
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

            return Column(
              children: <Widget>[
                if (showDateHeader)
                  Column(
                    children: [
                      if (index == 0) buildHeader(totalExpense, totalIncome),
                      ListTile(
                        visualDensity: const VisualDensity(
                          vertical: VisualDensity.minimumDensity,
                        ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Dismissible(
                    key: Key(currentBilling.id.toString()),
                    onDismissed: (direction) {
                      _removeBilling(context, index);
                    },
                    background: Container(
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      margin: EdgeInsets.only(
                        top: showDateHeader ? 0 : 6,
                      ),
                      color: currentBilling.type == BillingType.expense
                          ? Colors.red.shade50
                          : Colors.green.shade50,
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
                          visualDensity: VisualDensity.compact,
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
                ),
              ],
            );
          },
        );
      },
    );
  }

  GestureDetector buildHeader(Decimal totalExpense, Decimal totalIncome) {
    return GestureDetector(
      onTap: () {
        _loadImage();
      },
      onHorizontalDragEnd: (longPressDetails) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                PreviewPage(
              image: image,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 1.0);
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
      },
      child: Stack(
        children: [
          image,
          Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'total expense: $totalExpense, total income: $totalIncome',
                  style: TextStyle(fontSize: 16, color: color),
                ),
              )),
        ],
      ),
    );
  }

  Future<PaletteGenerator> getImageMainColor(double imageWidth,
      double imageHeight, ImageProvider<Object> image) async {
    var rect = Rect.fromLTRB(0, imageHeight * 4 / 5, imageWidth, imageHeight);
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
