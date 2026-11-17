import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  test('los 17 iconos del sistema de diseno existen y son distintos', () {
    const iconos = <IconData>[
      LucideIcons.calculator,
      LucideIcons.trendingUp,
      LucideIcons.share2,
      LucideIcons.copy,
      LucideIcons.chevronDown,
      LucideIcons.arrowUpDown,
      LucideIcons.menu,
      LucideIcons.info,
      LucideIcons.settings,
      LucideIcons.badgeCheck,
      LucideIcons.cloudOff,
      LucideIcons.clock,
      LucideIcons.circleCheck,
      LucideIcons.star,
      LucideIcons.pencil,
      LucideIcons.arrowUpRight,
      LucideIcons.arrowDownRight,
    ];

    expect(iconos, hasLength(17));
    expect(iconos.map((icono) => icono.codePoint).toSet(), hasLength(17));
  });
}
