import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:noted/constants.dart';

/// Describes the general themes for colors and texts that will be applied
/// to the app. We use the FlexThemeData for our themes. You can make modifications
/// and replace them by visiting [https://rydmike.com/flexcolorscheme/themesplayground-v5/#/].
/// Try it out!
class AppTheme {
  /// Defines the light theme for the app
  static final lightTheme = FlexThemeData.light(
    fontFamily: robotoFontFamily,
    scheme: FlexScheme.red,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 4,
    appBarOpacity: 0.95,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      blendOnColors: false,
      inputDecoratorRadius: 36.0,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
  );

  /// Defines the dark theme for the app
  static final darkTheme = FlexThemeData.dark(
    fontFamily: robotoFontFamily,
    scheme: FlexScheme.red,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 4,
    appBarStyle: FlexAppBarStyle.background,
    appBarOpacity: 0.90,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 30,
      inputDecoratorRadius: 36.0,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
  );
}
