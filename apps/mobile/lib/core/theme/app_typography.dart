import 'package:material_ui/material_ui.dart';

/// Escala tipográfica de Cambiami (`design/DESIGN_SYSTEM.md` §4).
///
/// Nunito no expone la feature OpenType `tnum`, así que no se usa
/// `FontFeature.tabularFigures()`: los montos se alinean a la derecha con
/// `letterSpacing: 0` (§4, regla de respaldo).
abstract final class AppTypography {
  /// Familia única de la app v1. Se bundlea en `assets/fonts/`.
  static const String fontFamily = 'Nunito';

  /// 44 / 48, w800. Resultado en Bs de la calculadora.
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 44,
    height: 48 / 44,
    fontWeight: FontWeight.w800,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// 28 / 34, w800. Título de pantalla (solo splash/landing).
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w800,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// 22 / 28, w800. Título de pantalla (`Calculadora`, `Tasas`).
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w800,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// 18 / 24, w700. Nombre de moneda en tarjeta de tasa.
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w700,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// 28 / 32, w800. Monto en el campo activo.
  static const TextStyle amount = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 32 / 28,
    fontWeight: FontWeight.w800,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// 16 / 24, w400. Párrafos, legal.
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// 16 / 24, w600. Texto de botón, valores de fila.
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// 14 / 20, w600. Etiquetas de campo, tabs.
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// 12 / 16, w600. Fuente, fecha, estado, brecha.
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// 11 / 14, w700. Badges y texto sobre banner; único uso de mayúsculas.
  static const TextStyle micro = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    leadingDistribution: TextLeadingDistribution.even,
  );
}
