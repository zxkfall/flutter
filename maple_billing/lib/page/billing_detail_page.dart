import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/billing.dart';
import '../provider/billing_provider.dart';
import '../repository/billing_repository.dart';
import '../container/page_view_container.dart';
import '../view/kind_selection_view.dart';
import '../utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BillingDetailPage extends StatefulWidget {
  const BillingDetailPage({super.key, this.billing});

  final Billing? billing;

  @override
  State<BillingDetailPage> createState() => _BillingDetailPageState();
}

class _BillingDetailPageState extends State<BillingDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  BillingKind _selectedKind = BillingKind.food;
  BillingType _type = BillingType.expense;
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

      if (Decimal.parse(_amountController.text) == Decimal.zero) {
        Utils.showToast(AppLocalizations.of(context)!.amountCantNotBeEmpty, context);
        return;
      }
      final billingProvider = Provider.of<BillingProvider>(context, listen: false);

      // 获取当前页面的Navigator
      final currentNavigator = Navigator.of(context);

      if (widget.billing == null) {
        GetIt.I<BillingRepository>().insertBilling(billing).then((value) {
          billing.id = value;
          billingProvider.addBilling(billing);
        });
      } else {
        await GetIt.I<BillingRepository>().updateBilling(billing);
        billingProvider.updateBilling(billing);
      }

      // 使用当前页面的Navigator来进行导航
      currentNavigator.pop();
      currentNavigator.pushReplacement(MaterialPageRoute(builder: (_) => const PageViewContainer()));
    }
  }

  Future<void> _delete() async {
    if (widget.billing != null) {
      final billingProvider = Provider.of<BillingProvider>(context, listen: false);
      final currentNavigator = Navigator.of(context);
      await GetIt.I<BillingRepository>().deleteBilling(widget.billing!.id);
      billingProvider.removeBilling(widget.billing!.id);
      currentNavigator.pop();
      currentNavigator.pushReplacement(MaterialPageRoute(builder: (_) => const PageViewContainer()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        title: Text(widget.billing == null
            ? AppLocalizations.of(context)!.addBilling
            : AppLocalizations.of(context)!.editBilling),
        actions: [
          if (widget.billing != null)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            KindSelectionView(
              allKinds: _type == BillingType.expense ? getExpenseValues() : getIncomeValues(),
              selectedKind: _selectedKind,
              onKindSelected: (selectedKind) {
                setState(() {
                  _selectedKind = selectedKind;
                });
              },
              type: _type,
            ),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.amount,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
              ],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.pleaseEnterAmount;
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.description,
              ),
              validator: (value) {
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
                  child: Text(
                    DateFormat.yMMMd().format(_date), // 使用DateFormat格式化日期
                    style: const TextStyle(fontSize: 16.0), // 可以自定义文本样式
                  ),
                ),
                const Spacer(),
                DropdownButton<BillingType>(
                  value: _type,
                  onChanged: (BillingType? newValue) {
                    setState(() {
                      _type = newValue!;
                    });
                  },
                  items: BillingType.values.map<DropdownMenuItem<BillingType>>((BillingType value) {
                    return DropdownMenuItem<BillingType>(
                      value: value,
                      child: Text(value == BillingType.expense
                          ? AppLocalizations.of(context)!.expense
                          : AppLocalizations.of(context)!.income),
                    );
                  }).toList(),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _save,
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }

  BillingKind getDefaultKindForType(BillingKind kind, BillingType type) {
    if (type == BillingType.expense) {
      return getExpenseValues().contains(kind) ? kind : BillingKind.food;
    } else {
      return getIncomeValues().contains(kind) ? kind : BillingKind.salary;
    }
  }
}
