import 'package:connectivity_plus/connectivity_plus.dart';

/// Pemantau status koneksi internet menggunakan connectivity_plus.
class ConnectivityMonitor {
  final Connectivity _connectivity;

  ConnectivityMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Aliran perubahan konektivitas (true jika internet aktif).
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      return _isConnectedFromResults(results);
    });
  }

  /// Cek konektivitas saat ini secara instan.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _isConnectedFromResults(results);
  }

  bool _isConnectedFromResults(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    for (final r in results) {
      if (r != ConnectivityResult.none) {
        return true;
      }
    }
    return false;
  }
}
