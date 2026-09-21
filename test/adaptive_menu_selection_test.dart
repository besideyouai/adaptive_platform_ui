import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selected marker and disabled items preserve choice semantics', (
    tester,
  ) async {
    String? choice;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptivePopupMenuButton.widget<String>(
            items: const [
              AdaptivePopupMenuItem<String>(
                label: 'Current',
                value: 'current',
                selected: true,
              ),
              AdaptivePopupMenuItem<String>(
                label: 'Unavailable',
                value: 'disabled',
                enabled: false,
              ),
              AdaptivePopupMenuItem<String>(label: 'Next', value: 'next'),
            ],
            onSelected: (_, item) => choice = item.value,
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.tap(find.text('Unavailable'));
    await tester.pumpAndSettle();
    expect(choice, isNull);
    expect(find.text('Next'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(choice, 'next');
  });
  testWidgets('legacy iOS marks plain selected items and returns a choice', (
    tester,
  ) async {
    String? choice;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptivePopupMenuButton.widget<String>(
            platform: TargetPlatform.iOS,
            items: const [
              AdaptivePopupMenuItem<String>(
                label: 'Current',
                value: 'current',
                selected: true,
              ),
              AdaptivePopupMenuItem<String>(label: 'Next', value: 'next'),
            ],
            onSelected: (_, entry) => choice = entry.value,
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('✓ Current'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(choice, 'next');
  });
  testWidgets('disabled menu does not open or select', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdaptivePopupMenuButton.widget<String>(
            enabled: false,
            accessibilityLabel: 'Pick a value',
            items: const [
              AdaptivePopupMenuItem<String>(label: 'One', value: 'one'),
            ],
            onSelected: (_, entry) => calls++,
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('One'), findsNothing);
    expect(calls, 0);
  });
}
