// Smoke test for CI.
//
// The real app entry point (MyApp in lib/main.dart) initializes Firebase,
// OneSignal, and SharedPreferences in initState, none of which have platform
// channel mocks available in a plain `flutter test` run - pumping MyApp
// directly would throw MissingPluginException before rendering anything.
// Instead, this verifies the shared design-system widgets (used throughout
// the app's screens) render without error, which is enough to catch a build
// that's fundamentally broken (bad imports, syntax errors, broken theming).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vdsadmin/theme/app_theme.dart';

void main() {
  testWidgets('Design-system widgets render without error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppCard(
                child: const Text('Smoke test card'),
              ),
              PillButton(
                label: 'Tap me',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Smoke test card'), findsOneWidget);
    expect(find.text('Tap me'), findsOneWidget);

    await tester.tap(find.text('Tap me'));
    await tester.pump();
  });
}
