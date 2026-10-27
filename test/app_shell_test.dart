import 'package:fintrack/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app shell starts', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FintrackApp()));
    expect(find.text('Fintrack'), findsOneWidget);
  });
}
