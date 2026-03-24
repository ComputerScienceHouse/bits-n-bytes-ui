import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff470042),
      surfaceTint: Color(0xff9a358d),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff6c0164),
      onPrimaryContainer: Color(0xffea7bd7),
      secondary: Color(0xffa04100),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xfff76902),
      onSecondaryContainer: Color(0xff511d00),
      tertiary: Color(0xff000000),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff0a1350),
      onTertiaryContainer: Color(0xff777fc0),
      error: Color(0xff80002e),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffab0040),
      onErrorContainer: Color(0xffffb7c0),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff1c1b1b),
      onSurfaceVariant: Color(0xff444748),
      outline: Color(0xff747878),
      outlineVariant: Color(0xffc4c7c7),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
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

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff470042),
      surfaceTint: Color(0xff9a358d),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff6c0164),
      onPrimaryContainer: Color(0xffffb3ec),
      secondary: Color(0xff5f2400),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffb74c00),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff000000),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff0a1350),
      onTertiaryContainer: Color(0xff9aa2e5),
      error: Color(0xff720028),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffab0040),
      onErrorContainer: Color(0xfffff7f6),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff111111),
      onSurfaceVariant: Color(0xff333737),
      outline: Color(0xff4f5354),
      outlineVariant: Color(0xff6a6e6e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffffacec),
      primaryFixed: Color(0xffab449d),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff8e2a82),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xffb74c00),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff903a00),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff6068a7),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff48508d),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc9c6c5),
      surfaceBright: Color(0xfffdf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f2),
      surfaceContainer: Color(0xffebe7e7),
      surfaceContainerHigh: Color(0xffe0dcdb),
      surfaceContainerHighest: Color(0xffd4d1d0),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff470042),
      surfaceTint: Color(0xff9a358d),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff6c0164),
      onPrimaryContainer: Color(0xfffffafa),
      secondary: Color(0xff4f1d00),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff7e3200),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff000000),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff0a1350),
      onTertiaryContainer: Color(0xffc8cdff),
      error: Color(0xff5f0020),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff950037),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff292d2d),
      outlineVariant: Color(0xff464a4a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffffacec),
      primaryFixed: Color(0xff801c75),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff610059),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff7e3200),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff5a2100),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff3c4480),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff242d68),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbbb8b7),
      surfaceBright: Color(0xfffdf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f0ef),
      surfaceContainer: Color(0xffe5e2e1),
      surfaceContainerHigh: Color(0xffd7d4d3),
      surfaceContainerHighest: Color(0xffc9c6c5),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffacec),
      surfaceTint: Color(0xffffacec),
      onPrimary: Color(0xff5d0056),
      primaryContainer: Color(0xff6c0164),
      onPrimaryContainer: Color(0xffea7bd7),
      secondary: Color(0xffffb693),
      onSecondary: Color(0xff562000),
      secondaryContainer: Color(0xfff76902),
      onSecondaryContainer: Color(0xff511d00),
      tertiary: Color(0xffbcc3ff),
      onTertiary: Color(0xff222b66),
      tertiaryContainer: Color(0xff000748),
      onTertiaryContainer: Color(0xff7179b9),
      error: Color(0xffffb2bc),
      onError: Color(0xff670023),
      errorContainer: Color(0xffab0040),
      onErrorContainer: Color(0xffffb7c0),
      surface: Color(0xff141313),
      onSurface: Color(0xffe5e2e1),
      onSurfaceVariant: Color(0xffc4c7c7),
      outline: Color(0xff8e9192),
      outlineVariant: Color(0xff444748),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff9a358d),
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

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffcef0),
      surfaceTint: Color(0xffffacec),
      onPrimary: Color(0xff4a0045),
      primaryContainer: Color(0xffd569c3),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffd3c0),
      onSecondary: Color(0xff451800),
      secondaryContainer: Color(0xfff76902),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffd7daff),
      onTertiary: Color(0xff161f5a),
      tertiaryContainer: Color(0xff848ccd),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd1d6),
      onError: Color(0xff53001b),
      errorContainer: Color(0xffff4f79),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdadddd),
      outline: Color(0xffafb2b3),
      outlineVariant: Color(0xff8d9191),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff7e1a74),
      primaryFixed: Color(0xffffd7f2),
      onPrimaryFixed: Color(0xff270024),
      primaryFixedDim: Color(0xffffacec),
      onPrimaryFixedVariant: Color(0xff67005f),
      secondaryFixed: Color(0xffffdbcc),
      onSecondaryFixed: Color(0xff240900),
      secondaryFixedDim: Color(0xffffb693),
      onSecondaryFixedVariant: Color(0xff5f2400),
      tertiaryFixed: Color(0xffdfe0ff),
      onTertiaryFixed: Color(0xff000645),
      tertiaryFixedDim: Color(0xffbcc3ff),
      onTertiaryFixedVariant: Color(0xff28316c),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff454444),
      surfaceContainerLowest: Color(0xff070707),
      surfaceContainerLow: Color(0xff1e1d1d),
      surfaceContainer: Color(0xff282827),
      surfaceContainerHigh: Color(0xff333232),
      surfaceContainerHighest: Color(0xff3e3d3d),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffeaf6),
      surfaceTint: Color(0xffffacec),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffa5eb),
      onPrimaryContainer: Color(0xff1d001a),
      secondary: Color(0xffffece5),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffffb08a),
      onSecondaryContainer: Color(0xff1a0500),
      tertiary: Color(0xffefeeff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffb7beff),
      onTertiaryContainer: Color(0xff000435),
      error: Color(0xffffebed),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffacb8),
      onErrorContainer: Color(0xff210006),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeef0f1),
      outlineVariant: Color(0xffc0c3c4),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff7e1a74),
      primaryFixed: Color(0xffffd7f2),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffacec),
      onPrimaryFixedVariant: Color(0xff270024),
      secondaryFixed: Color(0xffffdbcc),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffffb693),
      onSecondaryFixedVariant: Color(0xff240900),
      tertiaryFixed: Color(0xffdfe0ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffbcc3ff),
      onTertiaryFixedVariant: Color(0xff000645),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff51504f),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f1f),
      surfaceContainer: Color(0xff313030),
      surfaceContainerHigh: Color(0xff3c3b3b),
      surfaceContainerHighest: Color(0xff484646),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
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
