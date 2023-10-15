import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../model/billing.dart';

class Utils {
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static Map<String, Decimal> calculateDailyTotal(DateTime targetDate, List<Billing> billings) {
    Decimal dailyTotalIncome = Decimal.zero;
    Decimal dailyTotalExpense = Decimal.zero;

    for (final billing in billings) {
      if (Utils.isSameDay(billing.date, targetDate)) {
        if (billing.type == BillingType.income) {
          dailyTotalIncome += billing.amount;
        } else {
          dailyTotalExpense += billing.amount;
        }
      }
    }
    return {
      'income': dailyTotalIncome,
      'expense': dailyTotalExpense,
    };
  }

  static showToast(String msg, FToast fToast) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check),
          const SizedBox(
            width: 12.0,
          ),
          Text(msg),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }
}
