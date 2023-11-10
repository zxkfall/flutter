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
  @override
  Widget build(BuildContext context) {
    return Consumer<BillingProvider>(builder: (context, provider, child) {
      return Scaffold(
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                ),
                onChanged: (text) {
                  provider.search(text);
                },
              ),
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
                            color: billing.type == BillingType.expense
                                ? Colors.red
                                : Colors.green),
                      ),
                    ),
                  ));
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
