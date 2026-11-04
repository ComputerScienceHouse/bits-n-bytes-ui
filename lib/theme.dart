import "package:flutter/material.dart";

/// App-wide theme mode. Driven live by the admin Debug tab's "Dark Mode"
/// toggle; [MaterialApp] listens to it (see main.dart). Defaults to following
/// the system setting.
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(
  ThemeMode.system,
);

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      // Brand purple. Container == base so buttons and accents read as one hue.
      primary: Color(0xff6c0164),
      surfaceTint: Color(0xff6c0164),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff6c0164),
      onPrimaryContainer: Color(0xffffffff),
      // Brand orange.
      secondary: Color(0xfff76902),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xfff76902),
      onSecondaryContainer: Color(0xffffffff),
      // Navy accent.
      tertiary: Color(0xff0a1350),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff0a1350),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffba1a1a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff1c1b1b),
      onSurfaceVariant: Color(0xff4c4448),
      outline: Color(0xff7d757a),
      outlineVariant: Color(0xffcfc4c9),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff322f30),
      inversePrimary: Color(0xffffacec),
      primaryFixed: Color(0xffffd7f2),
      onPrimaryFixed: Color(0xff390034),
      primaryFixedDim: Color(0xffffacec),
      onPrimaryFixedVariant: Color(0xff7d1873),
      secondaryFixed: Color(0xffffdbcc),
      onSecondaryFixed: Color(0xff351000),
      secondaryFixedDim: Color(0xffffb693),
      onSecondaryFixedVariant: Color(0xff7a3000),
      tertiaryFixed: Color(0xffdfe0ff),
      onTertiaryFixed: Color(0xff0a1350),
      tertiaryFixedDim: Color(0xffbcc3ff),
      onTertiaryFixedVariant: Color(0xff39427e),
      surfaceDim: Color(0xffddd9d8),
      surfaceBright: Color(0xfffdf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f2),
      surfaceContainer: Color(0xfff1edec),
      surfaceContainerHigh: Color(0xffebe7e7),
      surfaceContainerHighest: Color(0xffe5e2e1),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      // Same brand hues as light so buttons stay purple/orange with white text.
      primary: Color(0xff6c0164),
      surfaceTint: Color(0xff6c0164),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff6c0164),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xfff76902),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xfff76902),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff3c4480),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff3c4480),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xffffb4ab),
      onErrorContainer: Color(0xff690005),
      surface: Color(0xff141313),
      onSurface: Color(0xffe5e2e1),
      onSurfaceVariant: Color(0xffc4c7c7),
      outline: Color(0xff8e9192),
      outlineVariant: Color(0xff444748),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff6c0164),
      primaryFixed: Color(0xffffd7f2),
      onPrimaryFixed: Color(0xff390034),
      primaryFixedDim: Color(0xffffacec),
      onPrimaryFixedVariant: Color(0xff7d1873),
      secondaryFixed: Color(0xffffdbcc),
      onSecondaryFixed: Color(0xff351000),
      secondaryFixedDim: Color(0xffffb693),
      onSecondaryFixedVariant: Color(0xff7a3000),
      tertiaryFixed: Color(0xffdfe0ff),
      onTertiaryFixed: Color(0xff0a1350),
      tertiaryFixedDim: Color(0xffbcc3ff),
      onTertiaryFixedVariant: Color(0xff39427e),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff3a3939),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff1c1b1b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2b2a2a),
      surfaceContainerHighest: Color(0xff353434),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) {
    // Make every button shrink-wrap to its child + its own padding instead of
    // padding out to Material's default 64x48 tap target. Individual buttons
    // still control their look via `styleFrom(padding: ...)`.
    const compactButtonStyle = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      textButtonTheme: const TextButtonThemeData(style: compactButtonStyle),
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: compactButtonStyle,
      ),
      outlinedButtonTheme: const OutlinedButtonThemeData(
        style: compactButtonStyle,
      ),
      filledButtonTheme: const FilledButtonThemeData(style: compactButtonStyle),
    );
  }

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
