import 'package:demo/provider/billing_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/billing.dart';
import 'billing_detail_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingProvider>(builder: (context, provider, child) {
      return Scaffold(
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Search',
                      ),
                      onChanged: (text) {
                        provider.searchByDescription(text);
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      provider.clearSearch();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ),
              Row(
                children: [
                  DropdownButton(
                    value: searchType,
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All'),
                      ),
                      DropdownMenuItem(
                        value: 'Expense',
                        child: Text('Expense'),
                      ),
                      DropdownMenuItem(
                        value: 'Income',
                        child: Text('Income'),
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
                        getExpenseValues().contains(searchKind) ? provider.searchByKind(searchKind) : provider.searchByKind(null);
                      } else if (value == 'Income') {
                        searchType = 'Income';
                        provider.searchByType(BillingType.income);
                        getIncomeValues().contains(searchKind) ? provider.searchByKind(searchKind) : provider.searchByKind(null);
                      }
                    },
                  ),
                  DropdownButton<String>(
                    items: [const DropdownMenuItem(value: 'All', child: Text('All')),
                      if (searchType == 'Expense')
                        ...(getExpenseValues()
                            .map((e) => DropdownMenuItem(
                                value: e.name, child: Text(e.name)))
                            .toList())
                      else if (searchType == 'Income')
                        ...(getIncomeValues()
                            .map((e) => DropdownMenuItem(
                                value: e.name, child: Text(e.name)))
                            .toList())
                    ],
                    value: searchKind == null ? 'All' :
                    searchType == 'Expense' && getExpenseValues().contains(searchKind) ? searchKind!.name :
                    searchType == 'Income' && getIncomeValues().contains(searchKind) ? searchKind!.name : 'All',
                    onChanged: (value) {
                      if (value == 'All') {
                        searchKind = null;
                        provider.searchByKind(null);
                      } else if (searchType == 'Expense') {
                        searchKind = getExpenseValues()
                            .firstWhere((element) => element.name == value);
                        provider.searchByKind(searchKind);
                      } else if (searchType == 'Income') {
                        searchKind = getIncomeValues()
                            .firstWhere((element) => element.name == value);
                        provider.searchByKind(searchKind);
                      }
                    },
                  ),
                ],
              ),
              Expanded(
                // 使用 Expanded 来确保 ListView.builder 占用剩余的高度
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
                                builder: (_) =>
                                    BillingDetailPage(billing: billing),
                              ),
                            );
                          });
                        },
                        child: ListTile(
                          dense: true,
                          title: Text(billing.kind.name),
                          subtitle: Text(billing.description),
                          leading: Icon(
                            BillingIconMapper.getIcon(
                                billing.type, billing.kind),
                          ),
                          trailing: Text(
                            billing.amount.toString(),
                            style: TextStyle(
                              color: billing.type == BillingType.expense
                                  ? Colors.red
                                  : Colors.green,
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
      );
    });
  }
}
