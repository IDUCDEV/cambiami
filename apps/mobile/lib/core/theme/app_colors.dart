import 'package:material_ui/material_ui.dart';

/// Paleta de Cambiami (`design/DESIGN_SYSTEM.md` §3).
///
/// Es el único archivo del proyecto que puede contener valores [Color]
/// literales: los widgets consumen siempre un token de esta clase.
///
/// Regla dura de §3.3: `amber500`, `coral500` y `teal500` nunca se usan como
/// color de texto; para eso existen `stateWarnInk`, `stateOfflineInk` y
/// `stateOkInk`.
abstract final class AppColors {
  // §3.1 Paleta primitiva.
  static const Color indigo900 = Color(0xFF1D0F50);
  static const Color indigoSoft = Color(0xFFEDE9F7);
  static const Color teal500 = Color(0xFF20C6C8);
  static const Color tealSoft = Color(0xFFE3F8F8);
  static const Color coral500 = Color(0xFFFF705F);
  static const Color coralSoft = Color(0xFFFFF4F2);
  static const Color amber500 = Color(0xFFFFD166);
  static const Color amberSoft = Color(0xFFFFF6E0);

  // §3.2 Tokens semánticos (tema claro, único en v1).
  static const Color bgCanvas = Color(0xFFFFF9F1);
  static const Color bgSurface = Color(0xFFFFFFFF);
  static const Color bgInverse = Color(0xFF29243D);
  static const Color bgBrandSoft = Color(0xFFF1E4FE);

  static const Color textPrimary = Color(0xFF29243D);
  static const Color textSecondary = Color(0xFF6B6673);
  static const Color textTertiary = Color(0xFFA29DAE);
  static const Color textOnBrand = Color(0xFFFFFFFF);
  static const Color textOnInverse = Color(0xFFFFF9F1);
  static const Color textOnInverseSoft = Color(0xFFB9AEDC);

  static const Color borderSubtle = Color(0xFFEDEBF2);
  static const Color borderStrong = Color(0xFFDDD9E6);

  static const Color brandPrimary = Color(0xFF9944EE);
  static const Color brandPrimaryPressed = Color(0xFF7A2BD1);

  /// `focus/ring`: `brandPrimary` al 24 % de opacidad.
  static const Color focusRing = Color(0x3D9944EE);

  /// `shadow/floating` de §5: `rgba(41, 36, 61, 0.10)`.
  static const Color shadowFloating = Color(0x1A29243D);

  static const Color stateOkInk = Color(0xFF0A7476);
  static const Color stateWarnInk = Color(0xFF7A5200);
  static const Color stateOfflineInk = Color(0xFFC93B2A);
  static const Color stateOkBg = Color(0xFFE3F8F8);
  static const Color stateWarnBg = Color(0xFFFFD166);
  static const Color stateOfflineBg = Color(0xFFFFF0EE);

  // §3.4 Variación de tasa. Comparten hex con `state/*` y `textSecondary`,
  // pero son tokens distintos: un cambio de estado no debe mover la variación.
  static const Color variationUp = Color(0xFF0A7476);
  static const Color variationDown = Color(0xFFC93B2A);
  static const Color variationFlat = Color(0xFF6B6673);

  // §3.5 Tema oscuro (Fase 2). Se definen para no renombrar en el futuro,
  // pero la app v1 solo envía tema claro.
  static const Color darkBgCanvas = Color(0xFF1D0F50);
  static const Color darkBgSurface = Color(0xFF2A1C63);
  static const Color darkTextPrimary = Color(0xFFF6F2FF);
  static const Color darkTextSecondary = Color(0xFFB9AEDC);
}
