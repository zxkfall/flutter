import 'package:decimal/decimal.dart';
import 'package:demo/model/billing.dart';
import 'package:demo/page/billing_detail_page.dart';
import 'package:demo/provider/billing_provider.dart';
import 'package:demo/repository/billing_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'billing_detail_page_test.mocks.dart';
import 'widget_test.mocks.dart';

@GenerateNiceMocks([MockSpec<BillingProvider>(), MockSpec<BillingRepository>()])
void main() {
  final mockBillingRepository = MockBillingRepository();
  setUpAll(() {
    GetIt.I.registerSingleton<BillingRepository>(mockBillingRepository);
  });
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
    for (var kind in allExpenseKinds
        .where((value) => value != BillingKind.fruit)
        .toList()) {
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
        find.byIcon(
            BillingIconMapper.getIcon(BillingType.expense, BillingKind.fruit)),
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

    await widgetTester.tap(find.text('Jan 1, 2021'));
    await widgetTester.pumpAndSettle();
    await widgetTester.tap(find.text('2'));
    await widgetTester.pumpAndSettle();
    await widgetTester.tap(find.text('OK'));
    await widgetTester.pumpAndSettle();
    expect(
        find.byWidgetPredicate(
            (widget) => widget is Text && widget.data == 'Jan 2, 2021'),
        findsOneWidget);

    await widgetTester.tap(find.text('Expense'));
    await widgetTester.pumpAndSettle();
    await widgetTester.tap(find.text('Income'));
    await widgetTester.pumpAndSettle();
    expect(
        find.byWidgetPredicate((widget) =>
            widget is DropdownButton &&
            widget.value is BillingType &&
            widget.value == BillingType.income),
        findsOneWidget);
    final allIncomeKinds = getIncomeValues();
    for (var kind in allIncomeKinds
        .where((value) => value != BillingKind.salary)
        .toList()) {
      expect(
          find.byWidgetPredicate((widget) =>
              widget is Text &&
              widget.data == kind.name &&
              widget.style!.color == Colors.black),
          findsOneWidget);
      expect(find.byIcon(BillingIconMapper.getIcon(BillingType.income, kind)),
          findsWidgets);
    }
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Text &&
            widget.data == BillingKind.salary.name &&
            widget.style!.color == Colors.blue),
        findsOneWidget);
  });

  testWidgets('Should delete billing', (widgetTester) async {
    final mockBillingProvider = MockBillingProvider();

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
            create: (_) => mockBillingProvider,
          ),
        ],
        child: MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                // 返回一个按钮，点击后触发导航
                return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BillingDetailPage(billing: billing),
                      ),
                    );
                  },
                  child: const Text('Go to Billing Detail Page'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await widgetTester.pumpAndSettle();

    await widgetTester.tap(find.text('Go to Billing Detail Page'));
    await widgetTester.pumpAndSettle();

    await widgetTester.tap(find.byIcon(Icons.delete));
    await widgetTester.pumpAndSettle();
    expect(find.byIcon(Icons.delete), findsNothing);
    expect(find.text('Edit Billing'), findsNothing);

    verify(mockBillingProvider.removeBilling(1)).called(1);
    verify(mockBillingRepository.deleteBilling(1)).called(1);
  });

  // test save billing
  testWidgets('Should save billing', (widgetTester) async {
    final mockBillingProvider = MockBillingProvider();

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
            create: (_) => mockBillingProvider,
          ),
        ],
        child: MaterialApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                // 返回一个按钮，点击后触发导航
                return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BillingDetailPage(billing: billing),
                      ),
                    );
                  },
                  child: const Text('Go to Billing Detail Page'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await widgetTester.pumpAndSettle();

    await widgetTester.tap(find.text('Go to Billing Detail Page'));
    await widgetTester.pumpAndSettle();

    expect(
        find.byWidgetPredicate((widget) =>
            widget is Text &&
            widget.data == BillingKind.fruit.name &&
            widget.style!.color == Colors.blue),
        findsOneWidget);

    expect(
        find.byWidgetPredicate((widget) =>
            widget is Text &&
            widget.data == BillingKind.sport.name &&
            widget.style!.color == Colors.black),
        findsOneWidget);

    await widgetTester.tap(find.text('sport'));
    await widgetTester.pumpAndSettle();

    expect(
        find.byWidgetPredicate((widget) =>
            widget is Text &&
            widget.data == BillingKind.sport.name &&
            widget.style!.color == Colors.blue),
        findsOneWidget);

    expect(
        find.byWidgetPredicate((widget) =>
            widget is Text &&
            widget.data == BillingKind.fruit.name &&
            widget.style!.color == Colors.black),
        findsOneWidget);

    await widgetTester.tap(find.text('Save'));
    await widgetTester.pumpAndSettle();
    expect(find.text('Edit Billing'), findsNothing);

    verify(mockBillingProvider.updateBilling(argThat(predicate((billing) {
      final param = billing as Billing;
      return param.id == 1 &&
          param.type == BillingType.expense &&
          param.amount == Decimal.parse('100.00') &&
          param.date == DateTime(2021, 1, 1) &&
          param.description == 'fake expense' &&
          param.kind == BillingKind.sport;
    })))).called(1);
    verify(mockBillingRepository.updateBilling(argThat(predicate((billing) {
      final param = billing as Billing;
      return param.id == 1 &&
          param.type == BillingType.expense &&
          param.amount == Decimal.parse('100.00') &&
          param.date == DateTime(2021, 1, 1) &&
          param.description == 'fake expense' &&
          param.kind == BillingKind.sport;
    })))).called(1);
  });
}