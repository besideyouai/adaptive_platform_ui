import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final resize in [false, true]) {
      testWidgets('$platform respects background and keyboard resize=$resize', (
        tester,
      ) async {
        double? height;
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(800, 600),
                viewInsets: EdgeInsets.only(bottom: 100),
              ),
              child: AdaptiveScaffold(
                platform: platform,
                backgroundColor: Colors.amber,
                resizeToAvoidBottomInset: resize,
                body: LayoutBuilder(
                  builder: (_, constraints) {
                    height = constraints.maxHeight;
                    return const SizedBox.expand();
                  },
                ),
              ),
            ),
          ),
        );
        expect(height, resize ? 500 : 600);
        if (platform == TargetPlatform.iOS) {
          expect(
            tester
                .widget<CupertinoPageScaffold>(
                  find.byType(CupertinoPageScaffold),
                )
                .backgroundColor,
            Colors.amber,
          );
        } else {
          expect(
            tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
            Colors.amber,
          );
        }
        expect(find.byType(SafeArea), findsNothing);
        expect(find.byType(CupertinoNavigationBar), findsNothing);
      });
    }
  }
}
