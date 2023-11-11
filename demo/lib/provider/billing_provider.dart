import 'package:flutter/foundation.dart';
import '../model/billing.dart';

class BillingProvider with ChangeNotifier {
  List<Billing> _billings = <Billing>[];

  List<Billing> get billings => _billings;

  void setBillings(List<Billing> newBillings) {
    _billings = newBillings;
    _billings.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners(); // 通知监听器数据已更新
  }

  void removeBilling(int id) {
    _billings.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void updateBilling(Billing billing) {
    _billings.where((element) => element.id == billing.id).forEach((element) {
      element = billing;
    });
    notifyListeners();
  }

  void addBilling(Billing billing) {
    if (!_billings.any((element) => element.id == billing.id)) {
      _billings.add(billing);
      _billings.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  List<Billing> _searchResult = <Billing>[];

  List<Billing> get searchResult => _searchResult;

  String _searchDescription = '';

  BillingType? _searchType;

  BillingKind? _searchKind;

  void searchByDescription(String text) {
    _searchDescription = text;
    _search();
    notifyListeners();
  }

  void searchByType(BillingType? type) {
    _searchType = type;
    _search();
    notifyListeners();
  }

  void searchByKind(BillingKind? kind) {
    _searchKind = kind;
    _search();
    notifyListeners();
  }

  void _search() {
    _searchResult = _billings
        .where((element) => element.description.contains(_searchDescription)
        && (_searchType == null ? true : element.type == _searchType)
        && (_searchKind == null ? true : element.kind == _searchKind))
        .toList();
  }

  void clearSearch() {
    _searchResult.clear();
    notifyListeners();
  }
}
