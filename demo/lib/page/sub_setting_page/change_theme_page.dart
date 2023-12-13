import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/custom_theme.dart';
import '../../provider/theme_provider.dart';
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
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.onInverseSurface,
              child: Row(
                children: [
                  const Icon(Icons.color_lens, size: 36),
                  Text(
                    AppLocalizations.of(context)!.themeColor,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
            Expanded(
                child: GridView.count(
                    crossAxisCount: CustomTheme.themeColors.keys.length ~/ 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                  ...CustomTheme.themeColors.keys.map((key) {
                    var themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                    var isCurrentColor = themeProvider.themeColor == CustomTheme.themeColors[key];
                    return InkWell(
                      onTap: () {
                        themeProvider.setThemeColor(CustomTheme.themeColors[key]!);
                        setState(() {});
                      },
                      child: Container(
                        color: CustomTheme.themeColors[key]!.withOpacity(isCurrentColor ? 0.5 : 1),
                        child: Center(
                          child: Text(
                            isCurrentColor ? key : '',
                            style: TextStyle(
                              color:
                                  CustomTheme.themeColors[key]!.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ]))
          ],
        ));
  }
}
