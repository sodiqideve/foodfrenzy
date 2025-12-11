import 'package:flutter_test/flutter_test.dart';
import 'package:food_truck_frenzy/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FoodTruckFrenzyApp());

    // Verify the main menu is displayed
    expect(find.text('FOOD TRUCK'), findsOneWidget);
    expect(find.text('FRENZY'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
  });
}
