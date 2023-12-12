import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/custom_theme.dart';
import '../provider/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangeThemePage extends StatefulWidget {
  const ChangeThemePage({super.key});

  @override
  State<ChangeThemePage> createState() => _ChangeThemePageState();
}

class _ChangeThemePageState extends State<ChangeThemePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.changeTheme),
          backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        body: GridView.count(crossAxisCount: CustomTheme.themeColors.keys.length ~/ 5, children: [
          ...CustomTheme.themeColors.keys.map((key) {
            var themeProvider = Provider.of<ThemeProvider>(context, listen: false);
            var isCurrentColor = themeProvider.primaryColor == CustomTheme.themeColors[key];
            return InkWell(
              onTap: () {
                themeProvider.setTheme(CustomTheme.themeColors[key]!);
                setState(() {});
              },
              child: Container(
                color: CustomTheme.themeColors[key]!.withOpacity(isCurrentColor ? 0.5 : 1),
                child: Center(
                  child: Text(
                    isCurrentColor ? key : '',
                    style: TextStyle(
                      color: CustomTheme.themeColors[key]!.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }),
        ]));
  }
}
