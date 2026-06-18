import "package:flutter/material.dart";

class WorderTheme {
  final TextTheme textTheme;

  const WorderTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff904b40),
      surfaceTint: Color(0xff904b40),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdad4),
      onPrimaryContainer: Color(0xff73342a),
      secondary: Color(0xff695f12),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xfff2e48a),
      onSecondaryContainer: Color(0xff4f4700),
      tertiary: Color(0xff6f5c2e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xfffbe0a6),
      onTertiaryContainer: Color(0xff564419),
      error: Color(0xff685f12),
      onError: Color(0xffffffff),
      errorContainer: Color(0xfff1e58a),
      onErrorContainer: Color(0xff4f4800),
      surface: Color(0xfffff9ed),
      onSurface: Color(0xff1e1c13),
      onSurfaceVariant: Color(0xff534341),
      outline: Color(0xff857370),
      outlineVariant: Color(0xffd8c2be),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff333027),
      inversePrimary: Color(0xffffb4a8),
      primaryFixed: Color(0xffffdad4),
      onPrimaryFixed: Color(0xff3a0905),
      primaryFixedDim: Color(0xffffb4a8),
      onPrimaryFixedVariant: Color(0xff73342a),
      secondaryFixed: Color(0xfff2e48a),
      onSecondaryFixed: Color(0xff201c00),
      secondaryFixedDim: Color(0xffd5c871),
      onSecondaryFixedVariant: Color(0xff4f4700),
      tertiaryFixed: Color(0xfffbe0a6),
      onTertiaryFixed: Color(0xff251a00),
      tertiaryFixedDim: Color(0xffdec48c),
      onTertiaryFixedVariant: Color(0xff564419),
      surfaceDim: Color(0xffe0d9cc),
      surfaceBright: Color(0xfffff9ed),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffaf3e5),
      surfaceContainer: Color(0xfff4eddf),
      surfaceContainerHigh: Color(0xffeee8da),
      surfaceContainerHighest: Color(0xffe8e2d4),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff5e241b),
      surfaceTint: Color(0xff904b40),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffa1594d),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff3d3700),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff786e21),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff443409),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff7f6b3b),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff3d3700),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff776e21),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff9ed),
      onSurface: Color(0xff131109),
      onSurfaceVariant: Color(0xff413330),
      outline: Color(0xff5f4f4c),
      outlineVariant: Color(0xff7b6966),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff333027),
      inversePrimary: Color(0xffffb4a8),
      primaryFixed: Color(0xffa1594d),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff844137),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff786e21),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff5e5606),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff7f6b3b),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff655225),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffccc6b9),
      surfaceBright: Color(0xfffff9ed),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffaf3e5),
      surfaceContainer: Color(0xffeee8da),
      surfaceContainerHigh: Color(0xffe3dccf),
      surfaceContainerHighest: Color(0xffd7d1c4),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff511a12),
      surfaceTint: Color(0xff904b40),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff76362c),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff322d00),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff524a00),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff392a01),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff59471b),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff322d00),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff524a00),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff9ed),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff372927),
      outlineVariant: Color(0xff554643),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff333027),
      inversePrimary: Color(0xffffb4a8),
      primaryFixed: Color(0xff76362c),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff592018),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff524a00),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff393300),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff59471b),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff403006),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbeb8ab),
      surfaceBright: Color(0xfffff9ed),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f0e2),
      surfaceContainer: Color(0xffe8e2d4),
      surfaceContainerHigh: Color(0xffdad4c6),
      surfaceContainerHighest: Color(0xffccc6b9),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb4a8),
      surfaceTint: Color(0xffffb4a8),
      onPrimary: Color(0xff561e16),
      primaryContainer: Color(0xff73342a),
      onPrimaryContainer: Color(0xffffdad4),
      secondary: Color(0xffd5c871),
      onSecondary: Color(0xff373100),
      secondaryContainer: Color(0xff4f4700),
      onSecondaryContainer: Color(0xfff2e48a),
      tertiary: Color(0xffdec48c),
      onTertiary: Color(0xff3e2e04),
      tertiaryContainer: Color(0xff564419),
      onTertiaryContainer: Color(0xfffbe0a6),
      error: Color(0xffd4c871),
      onError: Color(0xff363100),
      errorContainer: Color(0xff4f4800),
      onErrorContainer: Color(0xfff1e58a),
      surface: Color(0xff15130b),
      onSurface: Color(0xffe8e2d4),
      onSurfaceVariant: Color(0xffd8c2be),
      outline: Color(0xffa08c89),
      outlineVariant: Color(0xff534341),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e2d4),
      inversePrimary: Color(0xff904b40),
      primaryFixed: Color(0xffffdad4),
      onPrimaryFixed: Color(0xff3a0905),
      primaryFixedDim: Color(0xffffb4a8),
      onPrimaryFixedVariant: Color(0xff73342a),
      secondaryFixed: Color(0xfff2e48a),
      onSecondaryFixed: Color(0xff201c00),
      secondaryFixedDim: Color(0xffd5c871),
      onSecondaryFixedVariant: Color(0xff4f4700),
      tertiaryFixed: Color(0xfffbe0a6),
      onTertiaryFixed: Color(0xff251a00),
      tertiaryFixedDim: Color(0xffdec48c),
      onTertiaryFixedVariant: Color(0xff564419),
      surfaceDim: Color(0xff15130b),
      surfaceBright: Color(0xff3c3930),
      surfaceContainerLowest: Color(0xff100e07),
      surfaceContainerLow: Color(0xff1e1c13),
      surfaceContainer: Color(0xff222017),
      surfaceContainerHigh: Color(0xff2c2a21),
      surfaceContainerHighest: Color(0xff38352b),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffd2cb),
      surfaceTint: Color(0xffffb4a8),
      onPrimary: Color(0xff48140d),
      primaryContainer: Color(0xffcc7b6e),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffebde84),
      onSecondary: Color(0xff2b2600),
      secondaryContainer: Color(0xff9d9241),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfff5d9a0),
      onTertiary: Color(0xff312400),
      tertiaryContainer: Color(0xffa58e5b),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffebde85),
      onError: Color(0xff2b2600),
      errorContainer: Color(0xff9c9242),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff15130b),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffeed7d3),
      outline: Color(0xffc2adaa),
      outlineVariant: Color(0xffa08c89),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e2d4),
      inversePrimary: Color(0xff74352b),
      primaryFixed: Color(0xffffdad4),
      onPrimaryFixed: Color(0xff2c0201),
      primaryFixedDim: Color(0xffffb4a8),
      onPrimaryFixedVariant: Color(0xff5e241b),
      secondaryFixed: Color(0xfff2e48a),
      onSecondaryFixed: Color(0xff141100),
      secondaryFixedDim: Color(0xffd5c871),
      onSecondaryFixedVariant: Color(0xff3d3700),
      tertiaryFixed: Color(0xfffbe0a6),
      onTertiaryFixed: Color(0xff181000),
      tertiaryFixedDim: Color(0xffdec48c),
      onTertiaryFixedVariant: Color(0xff443409),
      surfaceDim: Color(0xff15130b),
      surfaceBright: Color(0xff48443a),
      surfaceContainerLowest: Color(0xff090703),
      surfaceContainerLow: Color(0xff201e15),
      surfaceContainer: Color(0xff2a281f),
      surfaceContainerHigh: Color(0xff353229),
      surfaceContainerHighest: Color(0xff413d34),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffece9),
      surfaceTint: Color(0xffffb4a8),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffaea1),
      onPrimaryContainer: Color(0xff220000),
      secondary: Color(0xfffff29b),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffd1c46e),
      onSecondaryContainer: Color(0xff0e0b00),
      tertiary: Color(0xffffeecf),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffdac089),
      onTertiaryContainer: Color(0xff110a00),
      error: Color(0xfffff296),
      onError: Color(0xff000000),
      errorContainer: Color(0xffd0c46e),
      onErrorContainer: Color(0xff0e0b00),
      surface: Color(0xff15130b),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffffece9),
      outlineVariant: Color(0xffd4beba),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e2d4),
      inversePrimary: Color(0xff74352b),
      primaryFixed: Color(0xffffdad4),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffb4a8),
      onPrimaryFixedVariant: Color(0xff2c0201),
      secondaryFixed: Color(0xfff2e48a),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffd5c871),
      onSecondaryFixedVariant: Color(0xff141100),
      tertiaryFixed: Color(0xfffbe0a6),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffdec48c),
      onTertiaryFixedVariant: Color(0xff181000),
      surfaceDim: Color(0xff15130b),
      surfaceBright: Color(0xff535046),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff222017),
      surfaceContainer: Color(0xff333027),
      surfaceContainerHigh: Color(0xff3e3b32),
      surfaceContainerHighest: Color(0xff4a473d),
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
