import 'package:demo/model/billing.dart';
import 'package:demo/view/kind_selection_wrap_view.dart';
import 'package:demo/provider/billing_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Should change style when kind is chose', (widgetTester) async {
    final allKinds = [BillingKind.food, BillingKind.fruit];
    const selectedKind = BillingKind.food;
    const type = BillingType.expense;
    onKindSelected(BillingKind kind) {}

    await widgetTester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<BillingProvider>(
            create: (_) => BillingProvider(), // 这里你需要提供BillingProvider的实例
          ),
        ],
        child: Material(
            child: Directionality(
                textDirection: TextDirection.ltr,
                child: KindSelectionWrapView(
                  allKinds: allKinds,
                  selectedKind: selectedKind,
                  onKindSelected: onKindSelected,
                  type: type,
                ))),
      ),
    );
    await widgetTester.pump();

    final foodFinder = find.text('food');
    final foodWidget = foodFinder.evaluate().first.widget as Text;
    expect(foodWidget.style!.color, Colors.blue);
    final fruitFinder = find.text('fruit');
    final fruitWidget = fruitFinder.evaluate().first.widget as Text;
    expect(fruitWidget.style!.color, Colors.black);

    await widgetTester.tap(fruitFinder);
    await widgetTester.pump();
    final foodWidget2 = foodFinder.evaluate().first.widget as Text;
    expect(foodWidget2.style!.color, Colors.black);
    final fruitWidget2 = fruitFinder.evaluate().first.widget as Text;
    expect(fruitWidget2.style!.color, Colors.blue);
  });
}
