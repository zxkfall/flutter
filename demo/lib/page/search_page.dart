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
                      } else if (value == 'Expense') {
                        searchType = 'Expense';
                        provider.searchByType(BillingType.expense);
                      } else if (value == 'Income') {
                        searchType = 'Income';
                        provider.searchByType(BillingType.income);
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
