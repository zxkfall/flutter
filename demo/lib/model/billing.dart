import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

class Billing {
  Billing(
      {required this.id,
      required this.type,
      required this.amount,
      required this.date,
      required this.description,
      required this.kind});

  int id;
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
  expense,
  income,
}

extension BillingTypeExtension on BillingType {
  String get name {
    return toString().split('.').last;
  }
}

enum BillingKind {
  food,
  snack,
  fruit,
  traffic,
  shopping,
  entertainment,
  education,
  medical,
  digital,
  apparel,
  sport,
  travel,
  gift,
  pet,
  housing,
  communication,
  waterAndElectricity,
  redEnvelope,
  other,
  salary,
  bonus,
  manageFinances,
  lottery,
  dailyExpenses,
  help,
  cosmetics,
  wage,
  tobaccoAndWine,
  hobby,
}

class BillingIconMapper {
  static final Map<BillingType, Map<BillingKind, IconData>> iconMap = {
    BillingType.expense: {
      BillingKind.food: Icons.restaurant,
      BillingKind.snack: Icons.local_pizza,
      BillingKind.fruit: Icons.local_grocery_store,
      BillingKind.traffic: Icons.directions_car,
      BillingKind.shopping: Icons.shopping_cart,
      BillingKind.entertainment: Icons.movie,
      BillingKind.education: Icons.school,
      BillingKind.medical: Icons.local_hospital,
      BillingKind.digital: Icons.phone_android,
      BillingKind.apparel: Icons.accessibility,
      BillingKind.sport: Icons.directions_run,
      BillingKind.travel: Icons.airplanemode_active,
      BillingKind.gift: Icons.card_giftcard,
      BillingKind.pet: Icons.pets,
      BillingKind.housing: Icons.home,
      BillingKind.communication: Icons.phone,
      BillingKind.waterAndElectricity: Icons.flash_on,
      BillingKind.redEnvelope: Icons.card_giftcard,
      BillingKind.dailyExpenses: Icons.satellite_outlined,
      BillingKind.cosmetics: Icons.face,
      BillingKind.tobaccoAndWine: Icons.smoking_rooms,
      BillingKind.hobby: Icons.sports_esports,
      BillingKind.other: Icons.more_horiz,
      // 添加其他支出类型的图标映射
    },
    BillingType.income: {
      BillingKind.salary: Icons.attach_money,
      BillingKind.wage: Icons.attach_money,
      BillingKind.bonus: Icons.monetization_on,
      BillingKind.manageFinances: Icons.account_balance,
      BillingKind.lottery: Icons.casino,
      BillingKind.redEnvelope: Icons.card_giftcard,
      BillingKind.help: Icons.help,
      BillingKind.other: Icons.more_horiz
      // 添加其他收入类型的图标映射
    },
  };

  static IconData getIcon(BillingType type, BillingKind kind) {
    final typeMap = iconMap[type];
    if (typeMap != null) {
      final icon = typeMap[kind];
      if (icon != null) {
        return icon;
      }
    }
    return Icons.error_outline;
  }
}

List<BillingKind> getExpenseValues() {
  return [
    BillingKind.food,
    BillingKind.snack,
    BillingKind.fruit,
    BillingKind.traffic,
    BillingKind.shopping,
    BillingKind.entertainment,
    BillingKind.education,
    BillingKind.medical,
    BillingKind.digital,
    BillingKind.apparel,
    BillingKind.sport,
    BillingKind.travel,
    BillingKind.gift,
    BillingKind.pet,
    BillingKind.housing,
    BillingKind.communication,
    BillingKind.waterAndElectricity,
    BillingKind.redEnvelope,
    BillingKind.dailyExpenses,
    BillingKind.cosmetics,
    BillingKind.tobaccoAndWine,
    BillingKind.hobby,
    BillingKind.other,
  ];
}

List<BillingKind> getIncomeValues() {
  return [
    BillingKind.salary,
    BillingKind.wage,
    BillingKind.bonus,
    BillingKind.manageFinances,
    BillingKind.lottery,
    BillingKind.redEnvelope,
    BillingKind.help,
    BillingKind.other,
  ];
}

BillingKind stringToBillingKind(BillingType type, String value) {
  return type == BillingType.expense
      ? getExpenseValues().firstWhere(
          (element) =>
              element.name.toLowerCase() ==
              value.replaceAll(' ', '').toLowerCase(),
          orElse: () => BillingKind.other)
      : getIncomeValues().firstWhere(
          (element) =>
              element.name.toLowerCase() ==
              value.replaceAll(' ', '').toLowerCase(),
          orElse: () => BillingKind.other);
}
