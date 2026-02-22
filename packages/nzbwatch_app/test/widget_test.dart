import 'package:flutter_test/flutter_test.dart';
import 'package:nzbwatch/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: This may fail in a real environment because of library dependencies,
    // but for static analysis, the symbols must match.
    await tester.pumpWidget(const NzbWatchApp());
  });
}
