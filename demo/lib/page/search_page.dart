import 'package:demo/provider/billing_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage>{
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
                  return Card(
                    child: ListTile(
                      title: Text(provider.searchResult[index].description),
                      subtitle: Text(provider.searchResult[index].amount.toString()),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}