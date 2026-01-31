// Basic Flutter widget test for Travel Bro app
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:travel_bro/app.dart';

void main() {
  testWidgets('App smoke test - launches without error', (WidgetTester tester) async {
    // Build the app wrapped in ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: TravelBuddyApp(),
      ),
    );

    // Verify that the app launches - look for some expected widget
    // The app should at least render without throwing
    await tester.pump();
  });
}
