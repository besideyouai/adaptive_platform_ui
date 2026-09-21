import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<NavigatorState> openDialog(
    WidgetTester tester,
    VoidCallback onPressed, {
    bool enabled = true,
  }) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        home: const Scaffold(body: Text('Home')),
      ),
    );
    key.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Underlying page')),
      ),
    );
    await tester.pumpAndSettle();
    showCupertinoDialog<void>(
      context: key.currentContext!,
      builder: (_) => IOS26AlertDialog(
        title: 'Choice',
        actions: [
          AlertAction(title: 'Confirm', onPressed: onPressed, enabled: enabled),
        ],
      ),
    );
    await tester.pumpAndSettle();
    return key.currentState!;
  }

  // Desktop fallback exercises the same action gate as the native channel.
  // UIKit presentation/disposal still requires an iOS runtime check.
  testWidgets('repeated action cannot pop the underlying page', (tester) async {
    var calls = 0;
    final navigator = await openDialog(tester, () => calls++);
    final action = tester
        .widget<CupertinoDialogAction>(find.byType(CupertinoDialogAction))
        .onPressed!;
    action();
    action();
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.text('Underlying page'), findsOneWidget);
    expect(navigator.canPop(), isTrue);
  });

  testWidgets('late action after external pop is ignored', (tester) async {
    var calls = 0;
    final navigator = await openDialog(tester, () => calls++);
    final action = tester
        .widget<CupertinoDialogAction>(find.byType(CupertinoDialogAction))
        .onPressed!;
    navigator.pop();
    action();
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.text('Underlying page'), findsOneWidget);
    expect(navigator.canPop(), isTrue);
    action(); // Also safe once the dialog State has been disposed.
    expect(calls, 0);
  });

  testWidgets('disabled action does not confirm', (tester) async {
    var calls = 0;
    await openDialog(tester, () => calls++, enabled: false);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.text('Choice'), findsOneWidget);
  });
}
