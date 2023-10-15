import 'package:flutter/foundation.dart';
import 'billing.dart';

class BillingProvider with ChangeNotifier {
  List<Billing> _billings = <Billing>[];

  List<Billing> get billings => _billings;

  void setBillings(List<Billing> newBillings) {
    _billings = newBillings;
    notifyListeners(); // 通知监听器数据已更新
  }
}
