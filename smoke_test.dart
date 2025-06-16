import 'package:flutter_test/flutter_test.dart';
import 'package:family_travel_app/main.dart';

void main() {
  testWidgets('App builds without exceptions', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that no exceptions are thrown during the build process.
    expect(tester.takeException(), isNull);
  });
}


