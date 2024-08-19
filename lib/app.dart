import 'package:flutter/material.dart';
import 'package:noted/providers/preferences.dart';
import 'package:noted/routes/main_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:noted/routes/note_page.dart';
import 'package:noted/routes/settings_page.dart';
import 'package:noted/app_theme.dart';
import 'package:provider/provider.dart';

/// This class defines the general outline of the app, it's themes, locales, routes
/// and other settings that are related to the class containing the [MaterialApp] instance
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Preferences>(
      builder: ((_, value, __) {
        // This [AnimatedBuilder} helps gradually change the theme and locales
        // when requested by the user instead of suddenly shifting everything around.
        // it listens to the values provided by the Preferences provider.
        return AnimatedBuilder(
          animation: value,
          builder: (context, _) {
            return MaterialApp(
              restorationScopeId: 'Noted Material App',
              locale: value.locale,
              onGenerateTitle: (context) => AppLocalizations.of(context)!.title,
              // These two lines are needed for localizations. They set the supported
              // languages for this app and make the AppLocalizations.of callback available.
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: value.themeMode,
              onGenerateRoute: (settings) {
                if (settings.name == NotePage.routeName) {
                  // We have to cast settings.argument to Map<Object?, Object?>?
                  // If we don't, the state restoration API will throw an error.
                  return customPageRoute(NotePage(
                    noteValues: settings.arguments as Map<Object?, Object?>?,
                  ));
                } else if (settings.name == SettingsPage.routeName) {
                  return customPageRoute(const SettingsPage());
                }
                return null;
              },
              routes: {
                MainPage.routeName: (context) => const MainPage(),
              },
            );
          },
        );
      }),
    );
  }

  /// Makes a route with a custom slide animation.
  ///
  /// [route] : The route widget that gets animated
  PageRouteBuilder customPageRoute(Widget route) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      barrierColor: Colors.black54,
      pageBuilder: (context, animation, secondaryAnimation) => route,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))
                .animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: child,
      ),
    );
  }
}
