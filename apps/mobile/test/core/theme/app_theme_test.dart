import 'package:cambiami/core/theme/app_colors.dart';
import 'package:cambiami/core/theme/app_radius.dart';
import 'package:cambiami/core/theme/app_spacing.dart';
import 'package:cambiami/core/theme/app_theme.dart';
import 'package:cambiami/core/theme/app_typography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AppColors', () {
    test('respeta los primitivos de §3.1', () {
      expect(AppColors.indigo900, const Color(0xFF1D0F50));
      expect(AppColors.indigoSoft, const Color(0xFFEDE9F7));
      expect(AppColors.teal500, const Color(0xFF20C6C8));
      expect(AppColors.tealSoft, const Color(0xFFE3F8F8));
      expect(AppColors.coral500, const Color(0xFFFF705F));
      expect(AppColors.coralSoft, const Color(0xFFFFF4F2));
      expect(AppColors.amber500, const Color(0xFFFFD166));
      expect(AppColors.amberSoft, const Color(0xFFFFF6E0));
    });

    test('respeta los tokens semánticos de §3.2', () {
      expect(AppColors.bgCanvas, const Color(0xFFFFF9F1));
      expect(AppColors.bgSurface, const Color(0xFFFFFFFF));
      expect(AppColors.bgInverse, const Color(0xFF29243D));
      expect(AppColors.bgBrandSoft, const Color(0xFFF1E4FE));
      expect(AppColors.textPrimary, const Color(0xFF29243D));
      expect(AppColors.textSecondary, const Color(0xFF6B6673));
      expect(AppColors.textTertiary, const Color(0xFFA29DAE));
      expect(AppColors.textOnBrand, const Color(0xFFFFFFFF));
      expect(AppColors.textOnInverse, const Color(0xFFFFF9F1));
      expect(AppColors.textOnInverseSoft, const Color(0xFFB9AEDC));
      expect(AppColors.borderSubtle, const Color(0xFFEDEBF2));
      expect(AppColors.borderStrong, const Color(0xFFDDD9E6));
      expect(AppColors.brandPrimary, const Color(0xFF9944EE));
      expect(AppColors.brandPrimaryPressed, const Color(0xFF7A2BD1));
      expect(AppColors.focusRing, const Color(0x3D9944EE));
      expect(AppColors.stateOkInk, const Color(0xFF0A7476));
      expect(AppColors.stateWarnInk, const Color(0xFF7A5200));
      expect(AppColors.stateOfflineInk, const Color(0xFFC93B2A));
      expect(AppColors.stateOkBg, const Color(0xFFE3F8F8));
      expect(AppColors.stateWarnBg, const Color(0xFFFFD166));
      expect(AppColors.stateOfflineBg, const Color(0xFFFFF0EE));
    });

    test('define la variación y el tema oscuro sin activarlo', () {
      expect(AppColors.variationUp, AppColors.stateOkInk);
      expect(AppColors.variationDown, AppColors.stateOfflineInk);
      expect(AppColors.variationFlat, AppColors.textSecondary);
      expect(AppColors.darkBgCanvas, const Color(0xFF1D0F50));
      expect(AppColors.darkBgSurface, const Color(0xFF2A1C63));
      expect(AppColors.darkTextPrimary, const Color(0xFFF6F2FF));
      expect(AppColors.darkTextSecondary, const Color(0xFFB9AEDC));
    });
  });

  group('AppTypography', () {
    const styles = <TextStyle>[
      AppTypography.display,
      AppTypography.h1,
      AppTypography.h2,
      AppTypography.h3,
      AppTypography.amount,
      AppTypography.body,
      AppTypography.bodyStrong,
      AppTypography.label,
      AppTypography.caption,
      AppTypography.micro,
    ];

    test('usa Nunito y no depende de tnum', () {
      for (final style in styles) {
        expect(style.fontFamily, 'Nunito');
        expect(style.fontFeatures, isNull);
      }
    });

    test('respeta tamaños, interlíneas y pesos de §4', () {
      expect(AppTypography.display.fontSize, 44);
      expect(AppTypography.display.height, closeTo(48 / 44, 1e-9));
      expect(AppTypography.display.fontWeight, FontWeight.w800);

      expect(AppTypography.h1.fontSize, 28);
      expect(AppTypography.h1.height, closeTo(34 / 28, 1e-9));
      expect(AppTypography.h1.fontWeight, FontWeight.w800);

      expect(AppTypography.h2.fontSize, 22);
      expect(AppTypography.h2.height, closeTo(28 / 22, 1e-9));
      expect(AppTypography.h2.fontWeight, FontWeight.w800);

      expect(AppTypography.h3.fontSize, 18);
      expect(AppTypography.h3.height, closeTo(24 / 18, 1e-9));
      expect(AppTypography.h3.fontWeight, FontWeight.w700);

      expect(AppTypography.amount.fontSize, 28);
      expect(AppTypography.amount.height, closeTo(32 / 28, 1e-9));
      expect(AppTypography.amount.fontWeight, FontWeight.w800);

      expect(AppTypography.body.fontSize, 16);
      expect(AppTypography.body.height, 1.5);
      expect(AppTypography.body.fontWeight, FontWeight.w400);

      expect(AppTypography.bodyStrong.fontSize, 16);
      expect(AppTypography.bodyStrong.height, 1.5);
      expect(AppTypography.bodyStrong.fontWeight, FontWeight.w600);

      expect(AppTypography.label.fontSize, 14);
      expect(AppTypography.label.height, closeTo(20 / 14, 1e-9));
      expect(AppTypography.label.fontWeight, FontWeight.w600);

      expect(AppTypography.caption.fontSize, 12);
      expect(AppTypography.caption.height, closeTo(16 / 12, 1e-9));
      expect(AppTypography.caption.fontWeight, FontWeight.w600);

      expect(AppTypography.micro.fontSize, 11);
      expect(AppTypography.micro.height, closeTo(14 / 11, 1e-9));
      expect(AppTypography.micro.fontWeight, FontWeight.w700);
      expect(AppTypography.micro.letterSpacing, 0.4);
    });
  });

  group('AppSpacing y AppRadius', () {
    test('respeta la escala base 4 y el layout de §5', () {
      expect(
        <double>[
          AppSpacing.s1,
          AppSpacing.s2,
          AppSpacing.s3,
          AppSpacing.s4,
          AppSpacing.s5,
          AppSpacing.s6,
          AppSpacing.s8,
          AppSpacing.s10,
          AppSpacing.s12,
        ],
        <double>[4, 8, 12, 16, 20, 24, 32, 40, 48],
      );
      expect(AppSpacing.screenH, 24);
      expect(AppSpacing.contentTop, 12);
      expect(AppSpacing.contentBottom, 20);
      expect(AppSpacing.bottomBarReserve, 96);
      expect(AppSpacing.sectionGap, 24);
      expect(AppSpacing.innerGap, 12);
      expect(AppSpacing.statusBarHeight, 62);
      expect(AppSpacing.tabBarHeight, 72);
      expect(AppSpacing.tabBarInsetH, 16);
      expect(AppSpacing.tabBarInsetV, 12);
      expect(AppSpacing.fabSize, 60);
      expect(AppSpacing.fabOverhang, 16);
      expect(AppSpacing.minTouchTarget, 48);
    });

    test('respeta los radios de §5', () {
      expect(AppRadius.sm, 8);
      expect(AppRadius.md, 12);
      expect(AppRadius.lg, 16);
      expect(AppRadius.xl, 20);
      expect(AppRadius.pill, 999);
    });
  });

  group('AppShadows', () {
    test('define la sombra flotante de §5', () {
      final shadow = AppShadows.floating.single;
      expect(shadow.color, AppColors.shadowFloating);
      expect(shadow.offset, const Offset(0, 8));
      expect(shadow.blurRadius, 24);
    });
  });

  group('AppTheme.light', () {
    late ThemeData theme;

    Future<void> pumpTheme(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) {
              theme = Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    }

    testWidgets('expone el esquema de color del sistema de diseño', (
      tester,
    ) async {
      await pumpTheme(tester);

      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.brandPrimary);
      expect(theme.colorScheme.onPrimary, AppColors.textOnBrand);
      expect(theme.colorScheme.secondary, AppColors.brandPrimaryPressed);
      expect(theme.colorScheme.error, AppColors.stateOfflineInk);
      expect(theme.colorScheme.surface, AppColors.bgSurface);
      expect(theme.colorScheme.onSurface, AppColors.textPrimary);
      expect(theme.colorScheme.outline, AppColors.borderStrong);
      expect(theme.colorScheme.outlineVariant, AppColors.borderSubtle);
      expect(theme.colorScheme.inverseSurface, AppColors.bgInverse);
      expect(theme.colorScheme.onInverseSurface, AppColors.textOnInverse);
      expect(theme.scaffoldBackgroundColor, AppColors.bgCanvas);
      expect(theme.canvasColor, AppColors.bgCanvas);
      expect(theme.dividerColor, AppColors.borderSubtle);
      expect(theme.focusColor, AppColors.focusRing);
    });

    testWidgets('expone la escala tipográfica en los roles de Material', (
      tester,
    ) async {
      await pumpTheme(tester);

      expect(theme.textTheme.bodyLarge?.fontFamily, 'Nunito');
      expect(theme.textTheme.bodyLarge?.fontSize, 16);
      expect(theme.textTheme.bodyLarge?.fontWeight, FontWeight.w400);
      expect(theme.textTheme.bodyLarge?.height, 1.5);

      expect(theme.textTheme.headlineMedium?.fontSize, 22);
      expect(theme.textTheme.headlineMedium?.fontWeight, FontWeight.w800);

      expect(theme.textTheme.labelSmall?.fontSize, 11);
      expect(theme.textTheme.labelSmall?.letterSpacing, 0.4);
    });

    testWidgets('aplica Nunito 16/24 al texto por defecto', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: Text('Bs 1.234,56')),
        ),
      );

      final richText = tester.widget<RichText>(
        find.descendant(
          of: find.text('Bs 1.234,56'),
          matching: find.byType(RichText),
        ),
      );
      final style = richText.text.style;

      expect(style?.fontFamily, 'Nunito');
      expect(style?.fontSize, 16);
      expect(style?.fontWeight, FontWeight.w400);
      expect(style?.height, 1.5);
    });

    testWidgets('configura los componentes de §7', (tester) async {
      await pumpTheme(tester);

      expect(theme.appBarTheme.backgroundColor, AppColors.bgCanvas);
      expect(theme.appBarTheme.titleTextStyle?.color, AppColors.textPrimary);
      expect(theme.cardTheme.color, AppColors.bgSurface);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.dividerTheme.color, AppColors.borderSubtle);
      expect(theme.dividerTheme.thickness, 1);
      expect(theme.iconTheme.color, AppColors.textSecondary);
      expect(theme.bottomSheetTheme.backgroundColor, AppColors.bgSurface);
      expect(theme.inputDecorationTheme.fillColor, AppColors.bgSurface);

      final filled = theme.filledButtonTheme.style;
      expect(
        filled?.backgroundColor?.resolve(<WidgetState>{}),
        AppColors.brandPrimary,
      );
      expect(
        filled?.backgroundColor?.resolve(<WidgetState>{WidgetState.pressed}),
        AppColors.brandPrimaryPressed,
      );
      expect(filled?.minimumSize?.resolve(<WidgetState>{}), const Size(0, 48));
      expect(
        filled?.textStyle?.resolve(<WidgetState>{}),
        AppTypography.bodyStrong,
      );
    });
  });
}
