import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shazzysnap/core/theme/app_theme.dart';
import 'package:shazzysnap/presentation/widgets/common/glass_card.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        theme: AppTheme.darkTheme(AppTheme.defaultPrimary),
        home: Scaffold(body: child),
      ),
    );

void main() {
  group('GlassCard', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(_wrap(
        const GlassCard(child: Text('Hello GlassCard')),
      ));
      expect(find.text('Hello GlassCard'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(
        GlassCard(onTap: () => tapped = true, child: const Text('Tap me')),
      ));
      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });

    testWidgets('renders with gradient', (tester) async {
      await tester.pumpWidget(_wrap(
        GlassCard(
          gradient: AppTheme.heroGradient,
          child: const Text('Gradient'),
        ),
      ));
      expect(find.text('Gradient'), findsOneWidget);
    });
  });
}
