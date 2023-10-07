import 'package:decimal/decimal.dart';

class Billing {
  Billing(
      {required this.id,
      required this.type,
      required this.amount,
      required this.date,
      required this.description,
      required this.kind});

  final int id;
  final BillingType type;
  final Decimal amount;
  final DateTime date;
  final String description;
  final BillingKind kind;

  Map<String, dynamic> toMap() {
    return {
      'type': type == BillingType.income ? 0 : 1,
      'amount': amount.toString(),
      'date': date.toString(),
      'description': description,
      'kind': kind.index,
    };
  }
}

enum BillingType {
  income,
  expense,
}

enum BillingKind {
  cash,
  creditCard,
  debitCard,
  check,
  bankTransfer,
  other,
}

extension BillingTypeExtension on BillingType {
  String get name {
    // 使用 substring 方法去掉前缀
    return toString().split('.').last;
  }
}