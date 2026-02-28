import 'package:flutter/material.dart';

/// Convenience extensions on [BuildContext].
///
/// Reduces boilerplate: `context.colorScheme` instead of
/// `Theme.of(context).colorScheme`.
extension ContextExtensions on BuildContext {
  // ── Theme ───────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  // ── Media Query ─────────────────────────────────────────
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  Brightness get platformBrightness => mediaQuery.platformBrightness;
  bool get isDarkMode => platformBrightness == Brightness.dark;

  // ── Navigation ──────────────────────────────────────────
  NavigatorState get navigator => Navigator.of(this);

  // ── Snackbar ────────────────────────────────────────────
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void showErrorSnackBar(String message) => showSnackBar(message, isError: true);
}
