import 'package:decimal/decimal.dart';
import 'package:demo/model/billing.dart';
import 'package:demo/provider/billing_provider.dart';
import 'package:demo/provider/theme_provider.dart';
import 'package:demo/repository/billing_repository.dart';
import 'package:demo/main.dart';
import 'package:demo/store/my_shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  SharedPreferences.setMockInitialValues({});
  MySharedPreferences preferences = MySharedPreferences();
  await preferences.init();
  setUpAll(() async {
    GetIt.I.registerSingleton<BillingRepository>(HMockBillingRepository());
    GetIt.I.registerSingleton<MySharedPreferences>(preferences);
  });
  testWidgets('Should delete billing when swipe billing item', (widgetTester) async {
    await mockNetworkImages(() async => await widgetTester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<BillingProvider>(
                create: (_) => BillingProvider(), // 这里你需要提供BillingProvider的实例
              ),
              ChangeNotifierProvider<ThemeProvider>(
                create: (_) => ThemeProvider(),
              ),
            ],
            child: const MyApp(),
          ),
        ));

    await widgetTester.pump(); // swipe to delete
    expect(find.text('fake income'), findsOneWidget);
    expect(find.text('fake expense'), findsOneWidget);
    expect(find.text('Jan 1, 2021'), findsOneWidget);
    expect(find.text('Jan 2, 2021'), findsOneWidget);
    expect(find.text('Total: +\$100'), findsOneWidget);
    expect(find.text('Total: -\$100'), findsOneWidget);

    await widgetTester.drag(find.byType(Dismissible).last, const Offset(-500.0, 0.0));
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
  Future<int> insertBilling(Billing billing) {
    // TODO: implement insertBilling
    throw UnimplementedError();
  }

  @override
  Future<Billing> updateBilling(Billing billing) {
    // TODO: implement updateBilling
    throw UnimplementedError();
  }

  @override
  Future<void> batchInsertBilling(List<Billing> billings) {
    // TODO: implement batchInsertBilling
    throw UnimplementedError();
  }

  @override
  Future<int> clearBilling() {
    // TODO: implement clearBilling
    throw UnimplementedError();
  }
}
