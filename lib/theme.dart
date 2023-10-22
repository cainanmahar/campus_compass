import 'package:flutter/material.dart';

// Declare color scheme
final ColorScheme globalScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Colors.lightBlue[800]!,
    onPrimary: Colors.white,
    secondary: Colors.orange,
    onSecondary: Colors.black,
    error: Colors.red,
    onError: Colors.white,
    background: Colors.white,
    onBackground: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black);

final appBarTheme1 = AppBarTheme(backgroundColor: globalScheme.primary);

final ThemeData globalTheme = ThemeData(
  colorScheme: globalScheme,
);
