import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'billing.dart';
import 'billing_detail_page.dart';
import 'utils.dart';

class BillingListView extends StatelessWidget {
  final List<Billing> billings;
  final Function(int) removeBilling;

  const BillingListView({
    required this.billings,
    required this.removeBilling,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: billings.length,
      itemBuilder: (BuildContext context, int index) {
        final currentBilling = billings[index];
        final previousBilling = index > 0 ? billings[index - 1] : null;
        final showDateHeader = previousBilling == null ||
            !Utils.isSameDay(currentBilling.date, previousBilling.date);

        final dailyTotalMap =
            Utils.calculateDailyTotal(currentBilling.date, billings);

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
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: InkWell(
                onTap: () {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BillingDetailPage(
                            billing: currentBilling),
                      ),
                    );
                  });
                },
                highlightColor: Colors.transparent,
                child: ListTile(
                  title: Text(currentBilling.kind.name),
                  subtitle: Text(currentBilling.description),
                  leading: Icon(
                    BillingIconMapper.getIcon(
                        currentBilling.type, currentBilling.kind),
                  ),
                  trailing: Text(
                    currentBilling.type == BillingType.income
                        ? '+\$${currentBilling.amount.toStringAsFixed(2)}'
                        : '-\$${currentBilling.amount.toStringAsFixed(2)}',
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
