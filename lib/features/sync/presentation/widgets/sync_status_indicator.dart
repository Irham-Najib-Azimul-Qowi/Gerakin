import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/sync_status_controller.dart';

/// Widget indikator status sinkronisasi awan (cloud backup status badge).
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncStatusControllerProvider);
    final isSyncing = state.status.status == 'syncing' || state.isManualSyncing;

    Color statusColor;
    IconData icon;
    String statusText;

    if (isSyncing) {
      statusColor = Colors.orange;
      icon = Icons.sync_rounded;
      statusText = 'Menyinkronkan data...';
    } else if (state.status.status == 'error') {
      statusColor = Colors.red;
      icon = Icons.cloud_off_rounded;
      statusText = 'Gagal sinkronisasi';
    } else {
      statusColor = state.pendingCount > 0 ? Colors.amber : Colors.green;
      icon = state.pendingCount > 0 ? Icons.cloud_queue_rounded : Icons.cloud_done_rounded;
      statusText = state.pendingCount > 0 ? '${state.pendingCount} data tertunda' : 'Tersinkronisasi penuh';
    }

    return Card(
      elevation: 0,
      color: statusColor.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            isSyncing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  )
                : Icon(icon, color: statusColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    state.pendingCount > 0
                        ? 'Hubungkan ke internet untuk mencadangkan'
                        : 'Pencadangan cloud aktif & aman',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (state.pendingCount > 0 && !isSyncing)
              TextButton.icon(
                onPressed: () =>
                    ref.read(syncStatusControllerProvider.notifier).triggerManualSync(),
                icon: const Icon(Icons.sync_rounded, size: 14),
                label: const Text('Sync', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: statusColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
