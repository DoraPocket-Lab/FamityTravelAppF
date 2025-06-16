
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:family_travel_app/features/auth/presentation/profile_setup_screen.dart';

void main() {
  testWidgets('ProfileSetupScreen enables Save & Continue when form is valid', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileSetupScreen(),
        ),
      ),
    );

    // Initially, the FAB should be disabled
    expect(tester.widget<FloatingActionButton>(find.byType(FloatingActionButton)).onPressed, isNull);

    // Enter display name
    await tester.enterText(find.byType(TextFormField).first, 'Test User');
    await tester.pump();

    // Now the FAB should be enabled
    expect(tester.widget<FloatingActionButton>(find.byType(FloatingActionButton)).onPressed, isNotNull);

    // Test family size stepper
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    // Test adding child age
    await tester.tap(find.text('Add Child Age'));
    await tester.pump();
    expect(find.byType(Chip), findsOneWidget);

    // Test selecting travel style
    await tester.tap(find.text('CAR'));
    await tester.pump();
    expect(tester.widget<RadioListTile<TravelStyle>>(find.byWidgetPredicate(
      (widget) => widget is RadioListTile && widget.value == TravelStyle.car
    )).groupValue, TravelStyle.car);
  });
}


