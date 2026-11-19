import 'dart:math' as math;

import 'package:cambiami/core/theme/app_colors.dart';
import 'package:cambiami/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Mínimo WCAG AA para texto normal.
const double _aaNormalText = 4.5;

typedef _Pair = ({String label, Color foreground, Color background});

/// Pares texto/fondo de §3.2 y §3.3 que deben superar AA.
const List<_Pair> _textPairs = <_Pair>[
  (
    label: 'text/primary sobre bg/canvas',
    foreground: AppColors.textPrimary,
    background: AppColors.bgCanvas,
  ),
  (
    label: 'text/primary sobre bg/surface',
    foreground: AppColors.textPrimary,
    background: AppColors.bgSurface,
  ),
  (
    label: 'text/primary sobre bg/brand-soft',
    foreground: AppColors.textPrimary,
    background: AppColors.bgBrandSoft,
  ),
  (
    label: 'text/secondary sobre bg/canvas',
    foreground: AppColors.textSecondary,
    background: AppColors.bgCanvas,
  ),
  (
    label: 'text/secondary sobre bg/surface',
    foreground: AppColors.textSecondary,
    background: AppColors.bgSurface,
  ),
  (
    label: 'text/on-brand sobre brand/primary',
    foreground: AppColors.textOnBrand,
    background: AppColors.brandPrimary,
  ),
  (
    label: 'text/on-brand sobre brand/primary-pressed',
    foreground: AppColors.textOnBrand,
    background: AppColors.brandPrimaryPressed,
  ),
  (
    label: 'text/on-inverse sobre bg/inverse',
    foreground: AppColors.textOnInverse,
    background: AppColors.bgInverse,
  ),
  (
    label: 'text/on-inverse-soft sobre bg/inverse',
    foreground: AppColors.textOnInverseSoft,
    background: AppColors.bgInverse,
  ),
  (
    label: 'brand/primary sobre bg/canvas (ghost)',
    foreground: AppColors.brandPrimary,
    background: AppColors.bgCanvas,
  ),
  (
    label: 'state/offline-ink sobre bg/surface (error)',
    foreground: AppColors.stateOfflineInk,
    background: AppColors.bgSurface,
  ),
];

/// Chips de identidad de §3.6.
const List<_Pair> _identityPairs = <_Pair>[
  (
    label: 'BCV: indigo-900 sobre indigo-soft',
    foreground: AppColors.indigo900,
    background: AppColors.indigoSoft,
  ),
  (
    label: 'Euro: warn-ink sobre amber-soft',
    foreground: AppColors.stateWarnInk,
    background: AppColors.amberSoft,
  ),
  (
    label: 'USDT: brand/primary-pressed sobre bg/brand-soft',
    foreground: AppColors.brandPrimaryPressed,
    background: AppColors.bgBrandSoft,
  ),
  (
    label: 'Mi tasa: offline-ink sobre coral-soft',
    foreground: AppColors.stateOfflineInk,
    background: AppColors.coralSoft,
  ),
];

/// Variación de tasa de §3.4 sobre las dos superficies base.
const List<_Pair> _variationPairs = <_Pair>[
  (
    label: 'variation/up sobre bg/canvas',
    foreground: AppColors.variationUp,
    background: AppColors.bgCanvas,
  ),
  (
    label: 'variation/down sobre bg/canvas',
    foreground: AppColors.variationDown,
    background: AppColors.bgCanvas,
  ),
  (
    label: 'variation/flat sobre bg/canvas',
    foreground: AppColors.variationFlat,
    background: AppColors.bgCanvas,
  ),
  (
    label: 'variation/up sobre bg/surface',
    foreground: AppColors.variationUp,
    background: AppColors.bgSurface,
  ),
  (
    label: 'variation/down sobre bg/surface',
    foreground: AppColors.variationDown,
    background: AppColors.bgSurface,
  ),
  (
    label: 'variation/flat sobre bg/surface',
    foreground: AppColors.variationFlat,
    background: AppColors.bgSurface,
  ),
];

void main() {
  test('la fórmula de luminancia coincide con Color.computeLuminance', () {
    const colors = <Color>[
      AppColors.bgCanvas,
      AppColors.bgSurface,
      AppColors.bgInverse,
      AppColors.bgBrandSoft,
      AppColors.textPrimary,
      AppColors.textSecondary,
      AppColors.brandPrimary,
      AppColors.stateOkBg,
      AppColors.stateWarnBg,
      AppColors.stateOfflineBg,
    ];

    for (final color in colors) {
      expect(
        _relativeLuminance(color),
        closeTo(color.computeLuminance(), 1e-9),
        reason: 'luminancia de $color',
      );
    }
  });

  group('estados del dato (§3.3)', () {
    test('al_dia supera 4,5:1', () {
      // DS §3.3: 5,05:1.
      _expectAa(AppColors.stateOkInk, AppColors.stateOkBg, 'al_dia');
    });

    test('desactualizado supera 4,5:1', () {
      // DS §3.3: 4,80:1.
      _expectAa(
        AppColors.stateWarnInk,
        AppColors.stateWarnBg,
        'desactualizado',
      );
    });

    test('sin_conexión supera 4,5:1', () {
      // DS §3.3: 4,57:1.
      _expectAa(
        AppColors.stateOfflineInk,
        AppColors.stateOfflineBg,
        'sin_conexion',
      );
    });
  });

  group('texto sobre superficies (§3.2)', () {
    test('todos los pares pasan AA', () {
      for (final pair in _textPairs) {
        _expectAa(pair.foreground, pair.background, pair.label);
      }
    });
  });

  group('tintes de identidad (§3.6)', () {
    test('los cuatro chips pasan AA', () {
      for (final pair in _identityPairs) {
        _expectAa(pair.foreground, pair.background, pair.label);
      }
    });
  });

  group('variación de tasa (§3.4)', () {
    test('las tres variaciones pasan AA', () {
      for (final pair in _variationPairs) {
        _expectAa(pair.foreground, pair.background, pair.label);
      }
    });
  });

  group('ThemeData', () {
    test('los componentes del tema pasan AA', () {
      final theme = AppTheme.light;

      _expectAa(
        theme.appBarTheme.titleTextStyle!.color!,
        theme.appBarTheme.backgroundColor!,
        'AppBar',
      );
      _expectAa(
        theme.inputDecorationTheme.labelStyle!.color!,
        theme.inputDecorationTheme.fillColor!,
        'label de campo',
      );
      _expectAa(
        theme.inputDecorationTheme.errorStyle!.color!,
        theme.inputDecorationTheme.fillColor!,
        'error de campo',
      );
      _expectAa(
        AppColors.textPrimary,
        theme.cardTheme.color!,
        'texto sobre tarjeta',
      );

      final filled = theme.filledButtonTheme.style!;
      final filledForeground = filled.foregroundColor!.resolve(
        <WidgetState>{},
      )!;
      _expectAa(
        filledForeground,
        filled.backgroundColor!.resolve(<WidgetState>{})!,
        'FilledButton',
      );
      _expectAa(
        filledForeground,
        filled.backgroundColor!.resolve(<WidgetState>{WidgetState.pressed})!,
        'FilledButton pulsado',
      );

      final outlined = theme.outlinedButtonTheme.style!;
      _expectAa(
        outlined.foregroundColor!.resolve(<WidgetState>{})!,
        outlined.backgroundColor!.resolve(<WidgetState>{})!,
        'OutlinedButton',
      );
    });
  });
}

void _expectAa(Color foreground, Color background, String label) {
  final ratio = contrastRatio(foreground, background);
  expect(
    ratio,
    greaterThanOrEqualTo(_aaNormalText),
    reason: '$label: ${ratio.toStringAsFixed(2)}:1',
  );
}

/// Razón de contraste WCAG 2.x entre dos colores opacos.
double contrastRatio(Color foreground, Color background) {
  final first = _relativeLuminance(foreground);
  final second = _relativeLuminance(background);
  final lighter = math.max(first, second);
  final darker = math.min(first, second);
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color color) {
  double linearize(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    }
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * linearize(color.r) +
      0.7152 * linearize(color.g) +
      0.0722 * linearize(color.b);
}
