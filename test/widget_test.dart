import 'package:flutter_test/flutter_test.dart';
import 'package:pokemap/main.dart';

void main() {
  testWidgets('dashboard loads with monster control center',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Monster Control Center'), findsOneWidget);
    expect(find.text('Add Monsters'), findsOneWidget);
    expect(find.text('Monster Operations'), findsOneWidget);
  });
}
