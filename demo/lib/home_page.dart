import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import 'billing.dart';
import 'billing_repository.dart';
import 'utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Billing> _billings = <Billing>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadBillingData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _billings.length,
                itemBuilder: (BuildContext context, int index) {
                  final currentBilling = _billings[index];
                  final previousBilling =
                  index > 0 ? _billings[index - 1] : null;
                  // 判断是否需要显示日期表头
                  final showDateHeader = previousBilling == null ||
                      !Utils.isSameDay(currentBilling.date, previousBilling.date);

                  // 计算当前日期的总支出或总收入
                  final dailyTotalMap =
                  Utils.calculateDailyTotal(currentBilling.date, _billings);

                  return Column(
                    children: <Widget>[
                      if (showDateHeader)
                        Column(
                          children: [
                            ListTile(
                              title: Text(
                                DateFormat.yMMMd().format(currentBilling.date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(
                                'Total: ${dailyTotalMap['income'] == Decimal.zero ? '' : '+\$${dailyTotalMap['income']}'}'
                                    '${dailyTotalMap['income'] != Decimal.zero && dailyTotalMap['expense'] != Decimal.zero ? ', ' : ''}'
                                    '${dailyTotalMap['expense'] == Decimal.zero ? '' : '-\$${dailyTotalMap['expense']}'}',
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
                          removeBilling(index);
                        },
                        background: Container(
                          color: Colors.red, // 定义滑动时显示的背景颜色
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          title: Text(currentBilling.kind.name),
                          subtitle: Text(currentBilling.description),
                          leading: Icon(
                              BillingIconMapper.getIcon(currentBilling.kind)),
                          trailing: Text(currentBilling.type ==
                              BillingType.income
                              ? '+\$${currentBilling.amount.toStringAsFixed(2)}'
                              : '-\$${currentBilling.amount.toStringAsFixed(2)}'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/billing-detail');
        },
        tooltip: 'Add Billing',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> loadBillingData() async {
    _billings.clear();
    var list = await GetIt.I<BillingRepository>().billings();
    list.sort((a, b) => b.date.compareTo(a.date));
    _billings.addAll(list);
    setState(() {});
  }

  Future<void> removeBilling(int index) async {
    await GetIt.I<BillingRepository>().deleteBilling(_billings[index].id);
    setState(() {
      _billings.removeAt(index);
    });
  }
}