import 'package:flutter/material.dart';

class TopBarPlaceholder extends StatelessWidget {
  const TopBarPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}
