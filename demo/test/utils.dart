import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Color getIsSelectedColor(WidgetTester widgetTester, bool isSelected) {
  var materialElement = find.byType(MaterialApp).hasFound ? find.byType(MaterialApp) : find.byType(Material);
  var context = widgetTester.element(materialElement.first);
  return isSelected ? Theme.of(context).colorScheme.inversePrimary : Theme.of(context).colorScheme.onSurfaceVariant;
}
