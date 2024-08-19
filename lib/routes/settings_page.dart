import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:noted/providers/preferences.dart';
import 'package:provider/provider.dart';

/// The route widget of the Settings page
class SettingsPage extends StatefulWidget {
  /// The name of this route that gets used in navigation
  static const routeName = 'settings';

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
        centerTitle: true,
      ),
      body: ListView(children: [
        // The theme preferences ListTile
        ListTile(
          title: Text(localizations.theme),
          onTap: () =>
              Navigator.restorablePush(context, _buildThemeChoicesDialog),
        ),
        const Divider(),
        // The localization preferences ListTile
        ListTile(
          title: Text(localizations.language),
          onTap: () =>
              Navigator.restorablePush(context, _buildLocaleChoicesDialog),
        ),
      ]),
    );
  }

  /// The dialog that will be shown when the user taps on the theme settings.
  /// The user can then cahnge the theme of the app by tapping one of the options.
  static Route _buildThemeChoicesDialog(
      BuildContext context, Object? arguments) {
    return DialogRoute(
        context: context,
        builder: (context) {
          final localizations = AppLocalizations.of(context)!;
          ThemeMode? themeMode = context.read<Preferences>().themeMode;

          return AlertDialog(
            title: Text(localizations.themeDialogTitle),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(localizations.cancelButtonText)),
              TextButton(
                  onPressed: () {
                    context.read<Preferences>().setTheme(themeMode!);
                    Navigator.pop(context);
                  },
                  child: Text(localizations.okButtonText))
            ],
            content: StatefulBuilder(
              builder: (context, setStateDialog) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<ThemeMode>(
                        title: Text(localizations.lightTheme),
                        value: ThemeMode.light,
                        groupValue: themeMode,
                        onChanged: (value) =>
                            setStateDialog(() => themeMode = value)),
                    RadioListTile<ThemeMode>(
                        title: Text(localizations.darkTheme),
                        value: ThemeMode.dark,
                        groupValue: themeMode,
                        onChanged: (value) =>
                            setStateDialog(() => themeMode = value)),
                    RadioListTile<ThemeMode>(
                        title: Text(localizations.systemTheme),
                        value: ThemeMode.system,
                        groupValue: themeMode,
                        onChanged: (value) =>
                            setStateDialog(() => themeMode = value)),
                  ],
                ),
              ),
            ),
          );
        });
  }

  /// The dialog that will be shown when the user taps on the languages settings.
  /// The user can then cahnge the language of the app by tapping one of the options.
  static Route _buildLocaleChoicesDialog(
      BuildContext context, Object? arguments) {
    return DialogRoute(
        context: context,
        builder: (context) {
          final localizations = AppLocalizations.of(context)!;
          Locale? locale = context.read<Preferences>().locale;

          return AlertDialog(
            title: Text(localizations.languageDialogTitle),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(localizations.cancelButtonText)),
              TextButton(
                  onPressed: () {
                    if (locale == null) return;
                    context.read<Preferences>().setLocale(locale!);
                    Navigator.pop(context);
                  },
                  child: Text(localizations.okButtonText))
            ],
            content: StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<Locale>(
                        title: Text(localizations.english),
                        value: const Locale('en'),
                        groupValue: locale,
                        onChanged: (value) => setState(() => locale = value)),
                    RadioListTile<Locale>(
                        title: Text(localizations.persian),
                        value: const Locale('fa'),
                        groupValue: locale,
                        onChanged: (value) => setState(() => locale = value)),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
