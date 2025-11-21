import 'package:flutter/material.dart';

ThemeData buildTheme(BuildContext context) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.redAccent,
      brightness: Brightness.dark,
      primary: Colors.amber,
      secondary: Colors.cyanAccent,
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF121212),
    dividerColor: Colors.white.withOpacity(0.1),
    hoverColor: Colors.amber.withOpacity(0.05),
    focusColor: Colors.amber.withOpacity(0.1),
    splashFactory: InkRipple.splashFactory,
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.selected) ? Colors.amber : Colors.white70,
      ),
      trackColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.selected) ? Colors.amber.withOpacity(0.6) : Colors.white24,
      ),
      trackOutlineColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.selected) ? Colors.amber.withOpacity(0.8) : Colors.white30,
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: WidgetStateProperty.all(4),
      thumbVisibility: WidgetStateProperty.all(true),
      thumbColor: WidgetStateProperty.all(Colors.white24),
      radius: const Radius.circular(8),
    ),
    tooltipTheme: TooltipThemeData(
      waitDuration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      verticalOffset: 18,
      textStyle: const TextStyle(fontSize: 12, color: Colors.white70),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        color: Colors.grey.shade900,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: Colors.white.withOpacity(0.9)),
      displayMedium: TextStyle(color: Colors.white.withOpacity(0.9)),
      displaySmall: TextStyle(color: Colors.white.withOpacity(0.9)),
      headlineMedium: TextStyle(color: Colors.white.withOpacity(0.85)),
      headlineSmall: TextStyle(color: Colors.white.withOpacity(0.85)),
      titleLarge: TextStyle(color: Colors.white.withOpacity(0.85)),
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white60),
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.4),
    ),
  );
}