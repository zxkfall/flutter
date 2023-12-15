import 'package:maple_billing/page/chart_page.dart';
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

  String _searchDescription = '';

  BillingType? _searchType;

  BillingKind? _searchKind;

  DateTime? _startDate;

  DateTime? _endDate;

  bool _isAllDate = false;

  List<Billing> get searchResult => _searchResult;

  String get searchDescription => _searchDescription;

  BillingType? get searchType => _searchType;

  BillingKind? get searchKind => _searchKind;

  DateTime? get startDate => _startDate;

  DateTime? get endDate => _endDate;

  bool get isAllDate => _isAllDate;

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

  void searchByDateRange(DateTime? start, DateTime? end, bool isAllDate) {
    _startDate = start;
    _endDate = end;
    _isAllDate = isAllDate;
    _search();
    notifyListeners();
  }

  void _search() {
    _searchResult = _billings
        .where((billing) =>
            billing.description.contains(_searchDescription) &&
            (_searchType == null ? true : billing.type == _searchType) &&
            (_searchKind == null ? true : billing.kind == _searchKind) &&
            _filterByDate(billing))
        .toList();
  }

  bool _filterByDate(Billing billing) {
    if (_startDate == null && _endDate == null || _isAllDate) {
      return true;
    } else if (_startDate == null && _endDate != null) {
      return billing.date.isBefore(_endDate!);
    } else if (_startDate != null && _endDate == null) {
      return billing.date.isAfter(_startDate!);
    } else {
      return billing.date.isAfter(_startDate!) && billing.date.isBefore(_endDate!);
    }
  }

  void clearSearch() {
    _searchResult.clear();
    _searchDescription = '';
    _searchType = null;
    _searchKind = null;
    _startDate = null;
    _endDate = null;
    _isAllDate = false;
    notifyListeners();
  }

  BillingType chartBillingType = BillingType.expense;
  DateTime chartCurrentDate = DateTime.now();
  ChartPeriod chartPeriod = ChartPeriod.week;
}
