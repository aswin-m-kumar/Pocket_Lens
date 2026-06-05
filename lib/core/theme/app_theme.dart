import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kBgDeep,
  colorScheme: const ColorScheme.dark(
    surface: kBgCard,
    primary: kAccent,
    error: kColorExpense,
  ),
  cardTheme: const CardThemeData(
    color: kBgCard,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
  dividerTheme: const DividerThemeData(
    color: kBorderSubtle,
    thickness: 1,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: kBgCard,
    selectedItemColor: kAccent,
    unselectedItemColor: kTextMuted,
    showSelectedLabels: false,
    showUnselectedLabels: false,
    type: BottomNavigationBarType.fixed,
  ),
  useMaterial3: false,
);
