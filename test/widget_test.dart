import 'package:flutter_test/flutter_test.dart';
import 'package:snackify_app/main.dart';
import 'package:snackify_app/injection_container.dart' as di;

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Initialize dependency injection for mock database testing
    await di.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify splash screen displays the app name
    expect(find.text('Snakify'), findsOneWidget);
  });
}
