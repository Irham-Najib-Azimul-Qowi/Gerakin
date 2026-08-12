import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gerakin/main.dart';

void main() {
  testWidgets('GerakinApp renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GerakinApp(),
      ),
    );

    // Verifikasi bahwa app berhasil render dengan Auth Gateway page (halaman awal aplikasi)
    expect(find.text('GerakIn'), findsWidgets);
  });
}
