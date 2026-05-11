import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_work_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App loads bootstrap', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const NutriWorkApp());
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Personalized setup'), findsOneWidget);
  });
}
