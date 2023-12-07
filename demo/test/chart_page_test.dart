import 'package:demo/page/chart_page.dart';
import 'package:demo/provider/billing_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('should show empty chart page', (widgetTester) async {
    await widgetTester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<BillingProvider>(
            create: (_) => BillingProvider(),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: ChartPage(),
            ),
          ),
        ),
      ),
    );
    await widgetTester.pump();

    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('Year'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
  });
}
