import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gerakin/main.dart';
import 'package:gerakin/features/auth/domain/app_session_state.dart';
import 'package:gerakin/features/auth/presentation/controllers/app_session_controller.dart';
import 'package:gerakin/features/user/models/user_profile.dart';

/// Fake Notifier untuk membypass inisialisasi Firebase & ObjectBox pada widget test.
class FakeAppSessionNotifier extends AppSessionNotifier {
  @override
  AppSessionState build() {
    return const SessionSignedOut();
  }

  @override
  Future<void> startGuestSession() async {
    state = SessionGuest(
      UserProfile(
        id: 1,
        displayName: 'Guest',
        gender: 'none',
        birthDate: DateTime(2000, 1, 1),
        height: 170.0,
        weight: 60.0,
        wheelchairType: 'none',
        mobilityLevel: 'intermediate',
        dominantHand: 'right',
        rehabilitationGoal: 'rom',
        medicalNotes: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'local_only',
        isGuest: true,
        isActive: true,
      ),
    );
  }
}

void main() {
  testWidgets('GerakinApp renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSessionProvider.overrideWith(() => FakeAppSessionNotifier()),
        ],
        child: const GerakinApp(),
      ),
    );

    // Verifikasi bahwa app berhasil render dengan Auth Gateway page (halaman awal aplikasi)
    expect(find.text('GerakIn'), findsWidgets);
  });
}
