import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/billing.dart';
import '../page/billing_detail_page.dart';
import '../provider/billing_provider.dart';
import '../repository/billing_repository.dart';
import '../utils/utils.dart';

class BillingListView extends StatelessWidget {
  const BillingListView({
    Key? key,
  }) : super(key: key);

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
            return Column(
              children: <Widget>[
                if (showDateHeader)
                  Column(
                    children: [
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

  Future<void> _removeBilling(BuildContext context, int index) async {
    final billingProvider =
        Provider.of<BillingProvider>(context, listen: false);

    final billing = billingProvider.billings[index];
    await GetIt.I<BillingRepository>().deleteBilling(billing.id);

    final updatedBillings = await GetIt.I<BillingRepository>().billings();
    billingProvider.setBillings(updatedBillings);
  }
}
