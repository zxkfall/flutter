import 'package:decimal/decimal.dart';

class Billing {
  Billing(
      {required this.id,
      required this.type,
      required this.amount,
      required this.date,
      required this.description,
      required this.payment});

  final int id;
  final BillingType type;
  final Decimal amount;
  final DateTime date;
  final String description;
  final String payment;

  Map<String, dynamic> toMap() {
    return {
      'type': type == BillingType.income ? 0 : 1,
      'amount': amount,
      'date': date.toString(),
      'description': description,
      'payment': payment,
    };
  }
}

enum BillingType {
  income,
  expense,
}
