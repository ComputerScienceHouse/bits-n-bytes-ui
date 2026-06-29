import 'package:flutter/material.dart';

/// Builds the app text theme from fonts bundled as assets (see pubspec.yaml
/// `fonts:`). Previously this used `GoogleFonts.getTextTheme`, which downloaded
/// the font files over HTTP on first launch — a network-dependent startup stall
/// plus a reflow when the fonts swapped in. Applying bundled families avoids
/// both: the glyphs are present in the bundle from the first frame.
TextTheme createTextTheme(
    BuildContext context, String bodyFontFamily, String displayFontFamily) {
  TextTheme baseTextTheme = Theme.of(context).textTheme;
  TextTheme bodyTextTheme = baseTextTheme.apply(fontFamily: bodyFontFamily);
  TextTheme displayTextTheme =
      baseTextTheme.apply(fontFamily: displayFontFamily);
  TextTheme textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
  return textTheme;
}
