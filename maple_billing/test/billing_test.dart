import 'package:decimal/decimal.dart';
import 'package:maple_billing/model/billing.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){
  test('Should return a map when call toMap method', (){
    final billing = Billing(
      id: 1,
      type: BillingType.expense,
      amount: Decimal.parse('100.00'),
      date: DateTime.now(),
      description: 'test',
      kind: BillingKind.fruit,
    );
    final map = billing.toMap();
    expect(map['type'], 1);
    expect(map['amount'], '100');
    expect(map['date'], billing.date.toString());
    expect(map['description'], 'test');
    expect(map['kind'], BillingKind.fruit.index);
  });

  test('Should return expense when call name method', (){
    final name = BillingType.expense.name;
    expect(name, 'expense');
  });

  test('Should return food when call stringToBillingKind method', (){
    final expenseKind = stringToBillingKind(BillingType.expense, 'food');
    expect(expenseKind, BillingKind.food);

    final incomeKind = stringToBillingKind(BillingType.income, 'lottery');
    expect(incomeKind, BillingKind.lottery);
  });


}