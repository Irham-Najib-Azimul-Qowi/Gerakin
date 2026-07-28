import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';

/// Riverpod Provider untuk [GoRouter].
///
/// Menggunakan [Provider] agar router tetap singleton
/// selama lifecycle aplikasi.
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});
