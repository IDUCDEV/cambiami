/// Escala de espaciado y medidas de layout de Cambiami
/// (`design/DESIGN_SYSTEM.md` §5).
///
/// La escala es base 4. Las constantes de layout se aplican una sola vez en
/// el contenedor de contenido, nunca en el frame raíz.
abstract final class AppSpacing {
  // Escala (base 4).
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;

  // Layout.
  /// Padding horizontal de pantalla.
  static const double screenH = 24;

  /// Padding vertical superior del contenido.
  static const double contentTop = 12;

  /// Padding vertical inferior del contenido.
  static const double contentBottom = 20;

  /// Reserva inferior del scroll en pantallas con barra flotante.
  static const double bottomBarReserve = 96;

  /// Separación entre secciones.
  static const double sectionGap = 24;

  /// Separación dentro de una sección.
  static const double innerGap = 12;

  /// Alto del status bar; nunca se dibuja UI debajo.
  static const double statusBarHeight = 62;

  /// Alto de la tab bar flotante.
  static const double tabBarHeight = 72;

  /// Inset lateral de la tab bar.
  static const double tabBarInsetH = 16;

  /// Inset inferior de la tab bar.
  static const double tabBarInsetV = 12;

  /// Diámetro del FAB central.
  static const double fabSize = 60;

  /// Cuánto sobresale el FAB por encima de la tab bar.
  static const double fabOverhang = 16;

  /// Área táctil mínima.
  static const double minTouchTarget = 48;
}
