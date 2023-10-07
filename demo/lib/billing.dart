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
  expense,
  income,
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
      BillingKind.other: Icons.more_horiz,
      // 添加其他支出类型的图标映射
    },
    BillingType.income: {
      BillingKind.salary: Icons.attach_money,
      BillingKind.bonus: Icons.monetization_on,
      BillingKind.manageFinances: Icons.account_balance,
      BillingKind.lottery: Icons.casino,
      BillingKind.redEnvelope: Icons.card_giftcard,
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

extension BillingTypeExtension on BillingType {
  String get name {
    // 使用 substring 方法去掉前缀
    return toString().split('.').last;
  }
}
