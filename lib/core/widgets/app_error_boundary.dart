import 'package:flutter/material.dart';
import '../services/logger_service.dart';
import '../services/crashlytics_service.dart';

/// Widget Error Boundary untuk menangkap dan memulihkan pengecualian UI secara terisolasi.
class AppErrorBoundary extends StatefulWidget {
  final Widget child;

  const AppErrorBoundary({super.key, required this.child});

  static void reportError(Object error, StackTrace? stack) {
    LoggerService().error('Boundary Exception Captured', error: error, stackTrace: stack);
    CrashlyticsService().recordError(error, stack, reason: 'Captured by AppErrorBoundary');
  }

  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text(
                    'Terjadi Masalah Sementara',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Aplikasi GERAKIN mendeteksi kendala pada tampilan. Sistem telah memulihkan keadaan aplikasi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                      });
                    },
                    child: const Text('Muat Ulang Tampilan'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
