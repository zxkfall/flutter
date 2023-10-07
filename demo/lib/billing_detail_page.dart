import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

import 'billing.dart';
import 'billing_repository.dart';
import 'main.dart';

class BillingDetailPage extends StatefulWidget {
  const BillingDetailPage({Key? key, this.billing}) : super(key: key);

  final Billing? billing;

  @override
  State<BillingDetailPage> createState() => _BillingDetailPageState();
}

class _BillingDetailPageState extends State<BillingDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  BillingKind _selectedKind = BillingKind.other;
  BillingType _type = BillingType.income;
  DateTime _date = DateTime.now();
  FToast fToast = FToast();

  @override
  void initState() {
    super.initState();
    if (widget.billing != null) {
      _descriptionController.text = widget.billing!.description;
      _amountController.text = widget.billing!.amount.toString();
      _selectedKind = widget.billing!.kind;
      _type = widget.billing!.type;
      _date = widget.billing!.date;
    }
    fToast.init(context);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  _showToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check),
          const SizedBox(
            width: 12.0,
          ),
          Text(msg),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      var billing = Billing(
        id: widget.billing?.id ?? 0,
        type: _type,
        amount: Decimal.parse(_amountController.text),
        date: _date,
        description: _descriptionController.text,
        kind: _selectedKind,
      );

      if (int.parse(_amountController.text) == 0) {
        _showToast('Amount can not be 0');
        return;
      }

      // 获取当前页面的Navigator
      final currentNavigator = Navigator.of(context);

      if (widget.billing == null) {
        await GetIt.I<BillingRepository>().insertBilling(billing);
      } else {
        await GetIt.I<BillingRepository>().updateBilling(billing);
      }

      // 使用当前页面的Navigator来进行导航
      currentNavigator.pop();
      currentNavigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const MyHomePage()));

      setState(() {});
    }
  }

  Future<void> _delete() async {
    if (widget.billing != null) {
      final currentNavigator = Navigator.of(context);
      await GetIt.I<BillingRepository>().deleteBilling(widget.billing!.id);
      currentNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.billing == null ? 'Add Billing' : 'Edit Billing'),
        actions: [
          if (widget.billing != null)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              validator: (value) {
                // if (value == null || value.isEmpty) {
                //   return 'Please enter description';
                // }
                return null;
              },
            ),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter amount';
                }
                return null;
              },
            ),
            DropdownButtonFormField<BillingKind>(
              value: _selectedKind,
              onChanged: (BillingKind? newValue) {
                setState(() {
                  _selectedKind = newValue!;
                });
              },
              items: BillingKind.values
                  .map<DropdownMenuItem<BillingKind>>((BillingKind value) {
                return DropdownMenuItem<BillingKind>(
                  value: value,
                  child: Text(value.name), // 可以自定义显示文本
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Kind',
              ),
              validator: (value) {
                if (value == null) {
                  return 'Please select a kind';
                }
                return null;
              },
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    var date = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        _date = date;
                      });
                    }
                  },
                  child: Text(_date.toString()),
                ),
                const Spacer(),
                DropdownButton<BillingType>(
                  value: _type,
                  onChanged: (BillingType? newValue) {
                    setState(() {
                      _type = newValue!;
                    });
                  },
                  items: BillingType.values
                      .map<DropdownMenuItem<BillingType>>((BillingType value) {
                    return DropdownMenuItem<BillingType>(
                      value: value,
                      child: Text(
                          value == BillingType.income ? 'Income' : 'Expense'),
                    );
                  }).toList(),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}