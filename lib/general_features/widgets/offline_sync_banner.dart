import 'package:flutter/material.dart';
import '../repository/gashi_repository.dart';

// ============================================================================
// OFFLINE & SYNC STATUS BANNER WIDGET
// ============================================================================

class OfflineSyncBanner extends StatelessWidget {
  const OfflineSyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GashiRepository.instance,
      builder: (context, _) {
        final repo = GashiRepository.instance;
        final isOnline = repo.isOnline;
        final pending = repo.pendingSyncCount;
        final isSyncing = repo.isSyncing;

        if (isOnline && pending == 0 && !isSyncing) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: !isOnline
                ? const Color(0xFFFEF3C7) // Amber for offline
                : const Color(0xFFE0F2FE), // Blue for syncing/pending
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: !isOnline ? const Color(0xFFFCD34D) : const Color(0xFFBAE6FD),
            ),
          ),
          child: Row(
            children: [
              Icon(
                !isOnline
                    ? Icons.cloud_off_outlined
                    : (isSyncing ? Icons.sync : Icons.cloud_queue_outlined),
                size: 20,
                color: !isOnline ? const Color(0xFFB45309) : const Color(0xFF0369A1),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  !isOnline
                      ? 'Offline Mode: Data is saved locally ($pending pending sync)'
                      : (isSyncing
                          ? 'Syncing offline records with database...'
                          : '$pending offline changes ready to sync'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: !isOnline ? const Color(0xFF92400E) : const Color(0xFF0C4A6E),
                  ),
                ),
              ),
              if (isOnline && pending > 0 && !isSyncing)
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => repo.syncPendingData(),
                  child: const Text(
                    'Sync Now',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

