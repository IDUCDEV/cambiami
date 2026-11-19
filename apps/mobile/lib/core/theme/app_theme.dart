import 'package:cambiami/core/theme/app_colors.dart';
import 'package:cambiami/core/theme/app_radius.dart';
import 'package:cambiami/core/theme/app_spacing.dart';
import 'package:cambiami/core/theme/app_typography.dart';
import 'package:material_ui/material_ui.dart';

/// Elevación de Cambiami (`design/DESIGN_SYSTEM.md` §5).
///
/// Por defecto no hay sombra: las tarjetas se separan con `borderSubtle`.
/// La sombra flotante es solo para la tab bar y el bottom sheet.
abstract final class AppShadows {
  /// `shadow/floating`: `0 8 24 rgba(41, 36, 61, 0.10)`.
  static const List<BoxShadow> floating = <BoxShadow>[
    BoxShadow(
      color: AppColors.shadowFloating,
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];
}

/// Tema claro de Cambiami.
///
/// El tema oscuro está definido en tokens (§3.5) pero no se activa en v1.
/// Ningún widget debe construir colores o estilos propios: consume
/// `Theme.of(context)` o los tokens de `AppColors`/`AppTypography`.
abstract final class AppTheme {
  /// Tema único de la app v1.
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: AppTypography.fontFamily,
    colorScheme: _colorScheme,
    scaffoldBackgroundColor: AppColors.bgCanvas,
    canvasColor: AppColors.bgCanvas,
    cardColor: AppColors.bgSurface,
    dividerColor: AppColors.borderSubtle,
    focusColor: AppColors.focusRing,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    textTheme: _textTheme,
    appBarTheme: _appBarTheme,
    cardTheme: _cardTheme,
    dividerTheme: _dividerTheme,
    iconTheme: _iconTheme,
    textSelectionTheme: _textSelectionTheme,
    bottomSheetTheme: _bottomSheetTheme,
    progressIndicatorTheme: _progressIndicatorTheme,
    filledButtonTheme: _filledButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
  );

  // §3.2: esquema explícito, sin `fromSeed`, para no inventar colores.
  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.brandPrimary,
    onPrimary: AppColors.textOnBrand,
    primaryContainer: AppColors.bgBrandSoft,
    onPrimaryContainer: AppColors.textPrimary,
    secondary: AppColors.brandPrimaryPressed,
    onSecondary: AppColors.textOnBrand,
    secondaryContainer: AppColors.tealSoft,
    onSecondaryContainer: AppColors.stateOkInk,
    tertiary: AppColors.indigo900,
    onTertiary: AppColors.textOnInverse,
    tertiaryContainer: AppColors.indigoSoft,
    onTertiaryContainer: AppColors.indigo900,
    error: AppColors.stateOfflineInk,
    onError: AppColors.textOnBrand,
    errorContainer: AppColors.stateOfflineBg,
    onErrorContainer: AppColors.stateOfflineInk,
    surface: AppColors.bgSurface,
    onSurface: AppColors.textPrimary,
    surfaceDim: AppColors.bgCanvas,
    surfaceBright: AppColors.bgSurface,
    surfaceContainerLowest: AppColors.bgSurface,
    surfaceContainerLow: AppColors.bgCanvas,
    surfaceContainer: AppColors.bgCanvas,
    surfaceContainerHigh: AppColors.borderSubtle,
    surfaceContainerHighest: AppColors.borderStrong,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.borderStrong,
    outlineVariant: AppColors.borderSubtle,
    shadow: AppColors.textPrimary,
    inverseSurface: AppColors.bgInverse,
    onInverseSurface: AppColors.textOnInverse,
    inversePrimary: AppColors.textOnInverseSoft,
    surfaceTint: Colors.transparent,
  );

  // §4: los roles de Material apuntan a los tokens del sistema de diseño.
  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppTypography.display,
    displayMedium: AppTypography.amount,
    headlineLarge: AppTypography.h1,
    headlineMedium: AppTypography.h2,
    headlineSmall: AppTypography.h3,
    titleLarge: AppTypography.h2,
    titleMedium: AppTypography.bodyStrong,
    titleSmall: AppTypography.label,
    bodyLarge: AppTypography.body,
    bodyMedium: AppTypography.body,
    bodySmall: AppTypography.caption,
    labelLarge: AppTypography.bodyStrong,
    labelMedium: AppTypography.label,
    labelSmall: AppTypography.micro,
  );

  static final AppBarThemeData _appBarTheme = AppBarThemeData(
    backgroundColor: AppColors.bgCanvas,
    foregroundColor: AppColors.textPrimary,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: AppTypography.h2.copyWith(color: AppColors.textPrimary),
  );

  static const CardThemeData _cardTheme = CardThemeData(
    color: AppColors.bgSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
      side: BorderSide(color: AppColors.borderSubtle),
    ),
  );

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColors.borderSubtle,
    thickness: 1,
    space: 1,
  );

  static const IconThemeData _iconTheme = IconThemeData(
    color: AppColors.textSecondary,
  );

  static const TextSelectionThemeData _textSelectionTheme =
      TextSelectionThemeData(
        cursorColor: AppColors.brandPrimary,
        selectionColor: AppColors.bgBrandSoft,
        selectionHandleColor: AppColors.brandPrimary,
      );

  static const BottomSheetThemeData _bottomSheetTheme = BottomSheetThemeData(
    backgroundColor: AppColors.bgSurface,
    modalBackgroundColor: AppColors.bgSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    modalElevation: 0,
    showDragHandle: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
  );

  static const ProgressIndicatorThemeData _progressIndicatorTheme =
      ProgressIndicatorThemeData(
        color: AppColors.brandPrimary,
        linearTrackColor: AppColors.borderSubtle,
      );

  // §7.5: alto 48, radio md, padding horizontal 20, texto body-strong.
  static const WidgetStatePropertyAll<Size> _buttonSize =
      WidgetStatePropertyAll<Size>(Size(0, AppSpacing.minTouchTarget));

  static const WidgetStatePropertyAll<EdgeInsetsGeometry> _buttonPadding =
      WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      );

  static final WidgetStatePropertyAll<OutlinedBorder> _buttonShape =
      WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      );

  static const WidgetStatePropertyAll<TextStyle> _buttonTextStyle =
      WidgetStatePropertyAll<TextStyle>(AppTypography.bodyStrong);

  static final FilledButtonThemeData _filledButtonTheme = FilledButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        _filledBackground,
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        _filledForeground,
      ),
      minimumSize: _buttonSize,
      padding: _buttonPadding,
      shape: _buttonShape,
      textStyle: _buttonTextStyle,
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll<Color>(
            AppColors.bgSurface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            _outlinedForeground,
          ),
          side: WidgetStateProperty.resolveWith<BorderSide?>(_outlinedSide),
          minimumSize: _buttonSize,
          padding: _buttonPadding,
          shape: _buttonShape,
          textStyle: _buttonTextStyle,
        ),
      );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith<Color>(_textForeground),
      minimumSize: _buttonSize,
      padding: _buttonPadding,
      shape: _buttonShape,
      textStyle: _buttonTextStyle,
    ),
  );

  static final InputDecorationThemeData
  _inputDecorationTheme = InputDecorationThemeData(
    filled: true,
    fillColor: AppColors.bgSurface,
    contentPadding: const EdgeInsets.all(AppSpacing.s4),
    border: _inputBorder(AppColors.borderStrong),
    enabledBorder: _inputBorder(AppColors.borderStrong),
    disabledBorder: _inputBorder(AppColors.borderSubtle),
    focusedBorder: _inputBorder(AppColors.brandPrimary, width: 2),
    errorBorder: _inputBorder(AppColors.stateOfflineInk),
    focusedErrorBorder: _inputBorder(AppColors.stateOfflineInk, width: 2),
    labelStyle: AppTypography.label.copyWith(color: AppColors.textSecondary),
    floatingLabelStyle: AppTypography.label.copyWith(
      color: AppColors.brandPrimary,
    ),
    hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
    helperStyle: AppTypography.caption.copyWith(color: AppColors.textSecondary),
    errorStyle: AppTypography.caption.copyWith(
      color: AppColors.stateOfflineInk,
    ),
    prefixIconColor: AppColors.textSecondary,
    suffixIconColor: AppColors.textSecondary,
  );

  static Color _filledBackground(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return AppColors.borderSubtle;
    }
    if (states.contains(WidgetState.pressed)) {
      return AppColors.brandPrimaryPressed;
    }
    return AppColors.brandPrimary;
  }

  static Color _filledForeground(Set<WidgetState> states) {
    return states.contains(WidgetState.disabled)
        ? AppColors.textTertiary
        : AppColors.textOnBrand;
  }

  static Color _outlinedForeground(Set<WidgetState> states) {
    return states.contains(WidgetState.disabled)
        ? AppColors.textTertiary
        : AppColors.textPrimary;
  }

  static BorderSide? _outlinedSide(Set<WidgetState> states) {
    final color = states.contains(WidgetState.disabled)
        ? AppColors.borderSubtle
        : AppColors.borderStrong;
    return BorderSide(color: color);
  }

  static Color _textForeground(Set<WidgetState> states) {
    return states.contains(WidgetState.disabled)
        ? AppColors.textTertiary
        : AppColors.brandPrimary;
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
