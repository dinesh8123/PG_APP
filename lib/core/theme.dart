import 'package:flutter/material.dart';

const kPrimary = Color(0xFF1B7F6B);
const kPrimaryDark = Color(0xFF0E5446);
const kPrimaryLight = Color(0xFF3FA68F);
const kBackground = Color(0xFFF2F6F5);
const kInk = Color(0xFF14231F);
const kMuted = Color(0xFF6B7C77);

const kHeroGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF21816D), kPrimary, kPrimaryDark],
);

ThemeData buildTheme({bool dark = false}) {
  final brightness = dark ? Brightness.dark : Brightness.light;
  final background = dark ? const Color(0xFF0C1B18) : kBackground;
  final surface = dark ? const Color(0xFF162B25) : Colors.white;

  final scheme = ColorScheme.fromSeed(
    seedColor: kPrimary,
    brightness: brightness,
  ).copyWith(
    primary: dark ? const Color(0xFF68D9BC) : kPrimary,
    onPrimary: dark ? const Color(0xFF07382B) : Colors.white,
    surface: surface,
    onSurface: dark ? const Color(0xFFE5F2EC) : kInk,
    onSurfaceVariant: dark ? const Color(0xFFADC4BA) : const Color(0xFF53665F),
    primaryContainer: dark ? const Color(0xFF244A3D) : const Color(0xFFE2F2EC),
    onPrimaryContainer: dark ? const Color(0xFFB3F4DC) : kPrimaryDark,
    outlineVariant: dark ? const Color(0xFF3C574C) : const Color(0xFFD9E2DF),
  );

  OutlineInputBorder border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    canvasColor: surface,
    cardColor: surface,
    dividerColor: scheme.outlineVariant,
    splashFactory: InkRipple.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF1D352C) : const Color(0xFFF0F6F4),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: border(scheme.outlineVariant),
      enabledBorder: border(scheme.outlineVariant),
      focusedBorder: border(scheme.primary, 1.8),
      errorBorder: border(scheme.error),
      focusedErrorBorder: border(scheme.error, 1.8),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      elevation: 0,
      height: 68,
      indicatorColor: scheme.primaryContainer,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
    ),
    popupMenuTheme: PopupMenuThemeData(color: surface),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}

Color readableAccent(BuildContext context, Color color) {
  if (Theme.of(context).brightness != Brightness.dark) return color;

  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness(hsl.lightness.clamp(0.68, 0.85)).toColor();
}
