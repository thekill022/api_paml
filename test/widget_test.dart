import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ucp2_paml/main.dart';

void main() {
  testWidgets('opens login after splash when no token exists', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const DriveEaseApp());
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke DriveEase'), findsOneWidget);
    expect(find.text('Register member'), findsOneWidget);
  });
}
