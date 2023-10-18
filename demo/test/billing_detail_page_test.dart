import 'package:decimal/decimal.dart';
import 'package:demo/model/billing.dart';
import 'package:demo/page/billing_detail_page.dart';
import 'package:demo/provider/billing_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Should show empty billing detail page', (widgetTester) async {
    await widgetTester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<BillingProvider>(
            create: (_) => BillingProvider(),
          ),
        ],
        child: const MaterialApp(
            home: Directionality(
                textDirection: TextDirection.ltr, child: BillingDetailPage())),
      ),
    );
    await widgetTester.pump();

    expect(find.text('Add Billing'), findsOneWidget);

    final allExpenseKinds = getExpenseValues();
    for (var kind in allExpenseKinds.skip(1)) {
      expect(
          find.byWidgetPredicate((widget) =>
              widget is Text &&
              widget.data == kind.name &&
              widget.style!.color == Colors.black),
          findsOneWidget);
      expect(find.byIcon(BillingIconMapper.getIcon(BillingType.expense, kind)),
          findsWidgets);
    }
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Text &&
            widget.data == allExpenseKinds.first.name &&
            widget.style!.color == Colors.blue),
        findsOneWidget);
    expect(
        find.byIcon(BillingIconMapper.getIcon(
            BillingType.expense, allExpenseKinds.first)),
        findsOneWidget);

    expect(
        find.byWidgetPredicate((widget) =>
            widget is TextField &&
            widget.decoration!.labelText == 'Amount' &&
            widget.controller!.text.isEmpty),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is TextField &&
            widget.decoration!.labelText == 'Description' &&
            widget.controller!.text.isEmpty),
        findsOneWidget);

    expect(
        find.byWidgetPredicate((widget) =>
            widget is DropdownButton &&
            widget.value is BillingType &&
            widget.value == BillingType.expense),
        findsOneWidget);
  });

  testWidgets('Should show edit billing detail page', (widgetTester) async {
    final billing = Billing(
      id: 1,
      type: BillingType.expense,
      amount: Decimal.parse('100.00'),
      date: DateTime(2021, 1, 1),
      description: 'fake expense',
      kind: BillingKind.fruit,
    );
    await widgetTester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<BillingProvider>(
            create: (_) => BillingProvider(),
          ),
        ],
        child: MaterialApp(
            home: Directionality(
                textDirection: TextDirection.ltr,
                child: BillingDetailPage(billing: billing))),
      ),
    );
    await widgetTester.pump();

    expect(find.text('Edit Billing'), findsOneWidget);

    final allExpenseKinds = getExpenseValues();
    for (var kind in allExpenseKinds.where((value) => value != BillingKind.fruit).toList()) {
      expect(
          find.byWidgetPredicate((widget) =>
              widget is Text &&
              widget.data == kind.name &&
              widget.style!.color == Colors.black),
          findsOneWidget);
      expect(find.byIcon(BillingIconMapper.getIcon(BillingType.expense, kind)),
          findsWidgets);
    }
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Text &&
            widget.data == BillingKind.fruit.name &&
            widget.style!.color == Colors.blue),
        findsOneWidget);
    expect(
        find.byIcon(BillingIconMapper.getIcon(
            BillingType.expense, BillingKind.fruit)),
        findsOneWidget);

    expect(
        find.byWidgetPredicate((widget) =>
            widget is TextField &&
            widget.decoration!.labelText == 'Amount' &&
            widget.controller!.text == '100'),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is TextField &&
            widget.decoration!.labelText == 'Description' &&
            widget.controller!.text == 'fake expense'),
        findsOneWidget);

    expect(
        find.byWidgetPredicate((widget) =>
            widget is DropdownButton &&
            widget.value is BillingType &&
            widget.value == BillingType.expense),
        findsOneWidget);
  });
}
