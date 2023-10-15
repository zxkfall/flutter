import 'package:decimal/decimal.dart';
import 'package:demo/billing.dart';
import 'package:demo/billing_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:demo/main.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'widget_test.mocks.dart';

// before run test, run this command: flutter pub run build_runner build --delete-conflicting-outputs
// steps:
// 1. add @GenerateMocks
// 2. run command: flutter pub run build_runner build --delete-conflicting-outputs
// 3. import 'widget_test.mocks.dart';
// 4. add mockRepository
// 5. add when(mockRepository.billings()).thenAnswer((_) async {
// 6. add await tester.pumpWidget(const MyApp());
// 7. add await tester.pump();
// 8. add expect(find.text('fake income'), findsOneWidget);
@GenerateNiceMocks([MockSpec<BillingRepository>()])
void main() {
  final mockRepository = MockBillingRepository();

  setUpAll(() async {
    GetIt.I.registerSingleton<BillingRepository>(mockRepository);
  });

  testWidgets('Test that all the billing data in the sqllite',
      (WidgetTester tester) async {
    when(mockRepository.billings()).thenAnswer((_) async {
      return [
        Billing(
          id: 1,
          type: BillingType.income,
          amount: Decimal.parse('100.00'),
          date: DateTime(2021, 1, 1),
          description: 'fake income',
          kind: BillingKind.food,
        ),
        Billing(
          id: 2,
          type: BillingType.expense,
          amount: Decimal.parse('100.00'),
          date: DateTime(2021, 1, 2),
          description: 'fake expense',
          kind: BillingKind.fruit,
        ),
        Billing(
          id: 3,
          type: BillingType.income,
          amount: Decimal.parse('50.00'),
          date: DateTime(2021, 1, 3),
          description: 'fake income for apparel',
          kind: BillingKind.apparel,
        ),
        Billing(
          id: 4,
          type: BillingType.expense,
          amount: Decimal.parse('200.00'),
          date: DateTime(2021, 1, 3),
          description: 'fake expense for digital',
          kind: BillingKind.digital,
        ),
      ];
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<BillingProvider>(
            create: (_) => BillingProvider(), // 这里你需要提供BillingProvider的实例
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    expect(find.text('Jan 1, 2021'), findsOneWidget);
    expect(find.text('fake income'), findsOneWidget);
    expect(find.text('+\$100.00'), findsNWidgets(1));
    expect(find.text('food'), findsNWidgets(1));
    expect(find.text('Total: +\$100'), findsOneWidget);
    expect(find.text('Jan 2, 2021'), findsOneWidget);
    expect(find.text('fake expense'), findsOneWidget);
    expect(find.text('-\$100.00'), findsNWidgets(1));
    expect(find.text('fruit'), findsNWidgets(1));
    expect(find.text('Total: -\$100'), findsOneWidget);
    expect(find.text('Jan 3, 2021'), findsOneWidget);
    expect(find.text('Total: +\$50, -\$200'), findsOneWidget);
    expect(find.text('fake income for apparel'), findsOneWidget);
    expect(find.text('+\$50.00'), findsNWidgets(1));
    expect(find.text('apparel'), findsNWidgets(1));
    expect(find.text('fake expense for digital'), findsOneWidget);
    expect(find.text('-\$200.00'), findsNWidgets(1));
    expect(find.text('digital'), findsNWidgets(1));
  });

  testWidgets('Should navigate to add billing page when click add button',
      (WidgetTester tester) async {
    when(mockRepository.billings()).thenAnswer((_) async {
      return [];
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<BillingProvider>(
            create: (_) => BillingProvider(), // 这里你需要提供BillingProvider的实例
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Add Billing'), findsOneWidget);
  });

  testWidgets('Should navigate to edit billing page when click billing item',
      (WidgetTester tester) async {
    when(mockRepository.billings()).thenAnswer((_) async {
      return [
        Billing(
          id: 1,
          type: BillingType.income,
          amount: Decimal.parse('100.00'),
          date: DateTime(2021, 1, 1),
          description: 'fake income',
          kind: BillingKind.salary,
        )
      ];
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<BillingProvider>(
            create: (_) => BillingProvider(), // 这里你需要提供BillingProvider的实例
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('fake income'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Billing'), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
    expect(find.text('salary'), findsOneWidget);
    expect(find.text('fake income'), findsOneWidget);
    expect(find.text('Jan 1, 2021'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
  });
}
