import 'package:decimal/decimal.dart';
import 'billing.dart';

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
}
