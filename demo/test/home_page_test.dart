import 'package:decimal/decimal.dart';
import 'package:demo/billing.dart';
import 'package:demo/billing_repository.dart';
import 'package:demo/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  setUpAll(() async {
    GetIt.I.registerSingleton<BillingRepository>(HMockBillingRepository());
  });
  testWidgets('Should delete billing when swipe billing item',
      (widgetTester) async {
    await widgetTester.pumpWidget(const MyApp());
    await widgetTester.pump();
    // swipe to delete
    expect(find.text('fake income'), findsOneWidget);
    expect(find.text('fake expense'), findsOneWidget);
    expect(find.text('Jan 1, 2021'), findsOneWidget);
    expect(find.text('Jan 2, 2021'), findsOneWidget);
    expect(find.text('Total: +\$100'), findsOneWidget);
    expect(find.text('Total: -\$100'), findsOneWidget);

    await widgetTester.drag(
        find.byType(Dismissible).last, const Offset(-500.0, 0.0));
    await widgetTester.pumpAndSettle();

    expect(find.text('fake income'), findsNothing);
    expect(find.text('fake expense'), findsOneWidget);
    expect(find.text('Jan 1, 2021'), findsNothing);
    expect(find.text('Jan 2, 2021'), findsOneWidget);
    expect(find.text('Total: +\$100'), findsNothing);
    expect(find.text('Total: -\$100'), findsOneWidget);
  });
}

class HMockBillingRepository implements BillingRepository {
  final List<Billing> _billings = [
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
  ];

  @override
  Future<List<Billing>> billings() async {
    return _billings;
  }

  @override
  Future<void> deleteBilling(int id) async {
    // 在这里模拟删除操作
    _billings.removeWhere((billing) => billing.id == id);
  }

  @override
  Future<Billing> billing(int id) {
    // TODO: implement billing
    throw UnimplementedError();
  }

  @override
  Future<void> insertBilling(Billing billing) {
    // TODO: implement insertBilling
    throw UnimplementedError();
  }

  @override
  Future<Billing> updateBilling(Billing billing) {
    // TODO: implement updateBilling
    throw UnimplementedError();
  }
}
