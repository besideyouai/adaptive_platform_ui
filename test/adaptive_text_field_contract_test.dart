import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    testWidgets('$platform preserves editing and outside-tap contract', (
      tester,
    ) async {
      final controller = TextEditingController();
      final focus = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      var outside = 0;
      Widget host(double height) => MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: height,
                child: AdaptiveTextField(
                  platform: platform,
                  controller: controller,
                  focusNode: focus,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  showCupertinoDecoration: false,
                  onTapOutside: (_) {
                    outside++;
                    focus.unfocus();
                  },
                  autofillHints: const [AutofillHints.email],
                  enableSuggestions: false,
                ),
              ),
              const SizedBox(height: 100, width: 100, child: Text('Outside')),
            ],
          ),
        ),
      );
      await tester.pumpWidget(host(200));
      await tester.enterText(find.byType(EditableText), 'A draft\nSecond line');
      await tester.pumpWidget(host(120));
      expect(controller.text, 'A draft\nSecond line');
      expect(focus.hasFocus, isTrue);
      if (platform == TargetPlatform.iOS) {
        expect(
          tester
              .widget<CupertinoTextField>(find.byType(CupertinoTextField))
              .decoration,
          isNull,
        );
      }
      await tester.tap(find.text('Outside'), kind: PointerDeviceKind.mouse);
      await tester.pump();
      expect(outside, 1);
      expect(focus.hasFocus, isFalse);
      expect(tester.takeException(), isNull);
    });
  }
}
