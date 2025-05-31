import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import 'colors.dart';

class AppTheme {
  //
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: createMaterialColor(scribblrPrimaryColor),
      primaryColor: scribblrPrimaryColor,
      scaffoldBackgroundColor: scaffoldPrimaryLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: scribblrPrimaryColor,
        outlineVariant: borderColor,
      ),
      fontFamily: GoogleFonts.nunito().fontFamily,
      useMaterial3: true,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.white),
      iconTheme: IconThemeData(color: textPrimaryColorGlobal),
      textTheme: GoogleFonts.lexendDecaTextTheme(),
      dialogBackgroundColor: Colors.white,
      unselectedWidgetColor: Colors.black,
      dividerColor: borderColor,
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
        ),
        backgroundColor: Colors.white,
      ),
      cardColor: cardColor,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark),
      ),
      dialogTheme: DialogTheme(shape: dialogShape()),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: createMaterialColor(scribblrPrimaryColor),
      primaryColor: scribblrPrimaryColor,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      ),
      scaffoldBackgroundColor: scaffoldDarkColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: scribblrPrimaryColor,
        outlineVariant: borderColor,
        onSurface: textPrimaryColorGlobal,
      ),
      fontFamily: GoogleFonts.lexendDeca().fontFamily,
      bottomNavigationBarTheme:
          BottomNavigationBarThemeData(backgroundColor: scaffoldSecondaryDark),
      iconTheme: IconThemeData(color: Colors.white),
      textTheme: GoogleFonts.lexendDecaTextTheme(),
      dialogBackgroundColor: scaffoldSecondaryDark,
      unselectedWidgetColor: Colors.white60,
      useMaterial3: true,
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
        ),
        backgroundColor: scaffoldDarkColor,
      ),
      dividerColor: dividerDarkColor,
      cardColor: cardDarkColor,
      dialogTheme: DialogTheme(shape: dialogShape()),
    );
  }
}
