import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';

import 'core/constants/app_constants.dart';
import 'core/router/router_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/logger_service.dart';
import 'core/services/crashlytics_service.dart';
import 'core/widgets/app_error_boundary.dart';

import 'data/local/objectbox_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Penanganan Pengecualian Global ──────────────────────────
  final logger = LoggerService();
  final crashlytics = CrashlyticsService();

  // ── Inisialisasi Firebase ────────────────────────────────────
  try {
    await Firebase.initializeApp();
    logger.info('Firebase Core berhasil diinisialisasi', category: 'MAIN');
  } catch (e, stack) {
    logger.error('Firebase.initializeApp gagal: $e', category: 'MAIN', error: e, stackTrace: stack);
  }

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    crashlytics.recordError(
      details.exception,
      details.stack,
      reason: details.context?.toString() ?? 'FlutterError captured',
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    crashlytics.recordError(error, stack, reason: 'PlatformDispatcher exception', fatal: true);
    return true;
  };

  logger.info('Inisialisasi aplikasi GERAKIN dimulai', category: 'MAIN');

  final objectBoxStore = await ObjectBoxStore.create();

  runApp(
    AppErrorBoundary(
      child: ProviderScope(
        overrides: [
          objectBoxStoreProvider.overrideWithValue(objectBoxStore.store),
        ],
        child: const GerakinApp(),
      ),
    ),
  );
}

/// Root widget aplikasi GERAKIN.
class GerakinApp extends ConsumerWidget {
  const GerakinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // ── Router ─────────────────────────────────────────
      routerConfig: router,
    );
  }
}
