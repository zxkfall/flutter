import 'package:maple_billing/provider/billing_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/billing.dart';
import '../view/top_bar_placeholder.dart';
import 'billing_detail_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  String? searchType = 'All';
  BillingKind? searchKind;
  DateTime startDate = DateTime.now().add(const Duration(days: -365));
  DateTime endDate = DateTime.now();
  bool allTime = false;
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingProvider>(builder: (context, provider, child) {
      descriptionController.text = provider.searchDescription;
      searchType = provider.searchType == null
          ? 'All'
          : provider.searchType == BillingType.expense
              ? 'Expense'
              : 'Income';
      searchKind = provider.searchKind;
      startDate = provider.startDate ?? DateTime.now().add(const Duration(days: -365));
      endDate = provider.endDate ?? DateTime.now();
      allTime = provider.isAllDate;

      var appLocalizations = AppLocalizations.of(context)!;
      return Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TopBarPlaceholder(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(left: 14, top: 12, bottom: 12, right: 14),
                                border: const OutlineInputBorder(),
                                labelText: appLocalizations.description,
                                isCollapsed: false,
                              ),
                              controller: descriptionController,
                              maxLines: 1,
                              onChanged: (text) {
                                provider.searchByDescription(text);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: IconButton(
                              onPressed: () {
                                provider.clearSearch();
                                setState(() {
                                  searchType = 'All';
                                  searchKind = null;
                                  startDate = DateTime.now().add(const Duration(days: -365));
                                  endDate = DateTime.now();
                                  allTime = false;
                                });
                              },
                              icon: const Icon(Icons.clear, size: 32),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            Text('${appLocalizations.type}: '),
                            DropdownButton(
                              value: searchType,
                              items: [
                                DropdownMenuItem(
                                  value: 'All',
                                  child: Text(appLocalizations.all),
                                ),
                                DropdownMenuItem(
                                  value: 'Expense',
                                  child: Text(appLocalizations.expense),
                                ),
                                DropdownMenuItem(
                                  value: 'Income',
                                  child: Text(appLocalizations.income),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == 'All') {
                                  searchType = 'All';
                                  provider.searchByType(null);
                                  provider.searchByKind(null);
                                } else if (value == 'Expense') {
                                  searchType = 'Expense';
                                  provider.searchByType(BillingType.expense);
                                  getExpenseValues().contains(searchKind)
                                      ? provider.searchByKind(searchKind)
                                      : provider.searchByKind(null);
                                } else if (value == 'Income') {
                                  searchType = 'Income';
                                  provider.searchByType(BillingType.income);
                                  getIncomeValues().contains(searchKind)
                                      ? provider.searchByKind(searchKind)
                                      : provider.searchByKind(null);
                                }
                              },
                            )
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text('${appLocalizations.kind}: '),
                            DropdownButton<String>(
                              items: [
                                DropdownMenuItem(value: 'All', child: Text(appLocalizations.all)),
                                if (searchType == 'Expense')
                                  ...(getExpenseValues()
                                      .map((e) => DropdownMenuItem(value: e.name, child: Text(e.name)))
                                      .toList())
                                else if (searchType == 'Income')
                                  ...(getIncomeValues()
                                      .map((e) => DropdownMenuItem(value: e.name, child: Text(e.name)))
                                      .toList())
                              ],
                              value: searchKind == null
                                  ? 'All'
                                  : searchType == 'Expense' && getExpenseValues().contains(searchKind)
                                      ? searchKind!.name
                                      : searchType == 'Income' && getIncomeValues().contains(searchKind)
                                          ? searchKind!.name
                                          : 'All',
                              onChanged: (value) {
                                if (value == 'All') {
                                  searchKind = null;
                                  provider.searchByKind(null);
                                } else if (searchType == 'Expense') {
                                  searchKind = getExpenseValues().firstWhere((element) => element.name == value);
                                  provider.searchByKind(searchKind);
                                } else if (searchType == 'Income') {
                                  searchKind = getIncomeValues().firstWhere((element) => element.name == value);
                                  provider.searchByKind(searchKind);
                                }
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('${appLocalizations.date}: '),
                        TextButton(
                            onPressed: () {
                              showDateRangePicker(
                                context: context,
                                firstDate: DateTime(1999),
                                lastDate: DateTime(2199),
                                initialDateRange: DateTimeRange(start: startDate, end: endDate),
                              ).then((value) {
                                setState(() {
                                  startDate = value!.start;
                                  endDate = value.end;
                                  provider.searchByDateRange(startDate, endDate, false);
                                });
                              });
                            },
                            child: Text(
                                '${DateFormat('yyyy.MM.dd').format(startDate)} - ${DateFormat('yyyy.MM.dd').format(endDate)}')),
                        Checkbox(
                          value: allTime,
                          onChanged: (value) {
                            if (value == true) {
                              allTime = true;
                              provider.searchByDateRange(startDate, endDate, true);
                            } else {
                              allTime = false;
                              provider.searchByDateRange(startDate, endDate, false);
                            }
                          },
                        ),
                        Text(appLocalizations.allTheTime),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: provider.searchResult.length,
                        itemBuilder: (context, index) {
                          var billing = provider.searchResult[index];
                          return Card(
                            child: InkWell(
                              onTap: () {
                                Future.delayed(const Duration(milliseconds: 150), () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => BillingDetailPage(billing: billing),
                                    ),
                                  );
                                });
                              },
                              child: ListTile(
                                dense: true,
                                title: Text(billing.kind.name),
                                subtitle: Text(billing.description),
                                leading: Icon(
                                  BillingIconMapper.getIcon(billing.type, billing.kind),
                                ),
                                trailing: Text(
                                  billing.amount.toString(),
                                  style: TextStyle(
                                    color: billing.type == BillingType.expense ? Colors.red : Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
