import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/file_picker_service.dart';
import '../../../core/sync/sync_provider.dart';
import '../../settings/presentation/widgets/section_header.dart';
import '../../settings/presentation/widgets/settings_card.dart';

class SyncSettingsScreen extends ConsumerWidget {
  const SyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dirPathAsync = ref.watch(syncDirectoryPathProvider);
    final syncState = ref.watch(syncStateProvider);

    final dirPath = dirPathAsync.asData?.value;
    final isConfigured = dirPath != null && dirPath.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Zero-Cloud Sync')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            const SectionHeader(title: 'CARTELLA DI SINCRONIZZAZIONE'),
            SettingsCard(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.folder_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    isConfigured ? dirPath : 'Nessuna cartella configurata',
                    style: TextStyle(
                      fontWeight: isConfigured
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    isConfigured
                        ? 'Cartella condivisa attiva per lo scambio dati'
                        : 'Seleziona una cartella Syncthing, USB o condivisa',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      FilledButton.icon(
                        key: const Key('sync_select_folder_button'),
                        icon: const Icon(Icons.folder_open_rounded, size: 18),
                        label: Text(
                          isConfigured ? 'Cambia cartella' : 'Scegli cartella',
                        ),
                        onPressed: () async {
                          final picker = ref.read(filePickerServiceProvider);
                          final path = await picker.pickDirectory(
                            dialogTitle:
                                'Seleziona cartella per Zero-Cloud Sync',
                          );
                          if (path != null) {
                            await ref
                                .read(syncDirectoryPathProvider.notifier)
                                .setDirectory(path);
                          }
                        },
                      ),
                      if (isConfigured) ...[
                        const SizedBox(width: 8),
                        OutlinedButton(
                          key: const Key('sync_remove_folder_button'),
                          child: const Text('Rimuovi'),
                          onPressed: () async {
                            await ref
                                .read(syncDirectoryPathProvider.notifier)
                                .setDirectory(null);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Funziona con Syncthing, chiavette USB, Nextcloud, WebDAV o cartelle di rete (SMB). '
                'Ogni dispositivo scrive esclusivamente nella propria casella; zero server e zero lock di database.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (isConfigured) ...[
              const SectionHeader(title: 'STATO SINCRONIZZAZIONE'),
              SettingsCard(
                children: [
                  ListTile(
                    leading: Icon(
                      syncState.isSyncing
                          ? Icons.sync
                          : (syncState.lastError != null
                                ? Icons.error_outline_rounded
                                : Icons.check_circle_outline_rounded),
                      color: syncState.lastError != null
                          ? colorScheme.error
                          : colorScheme.primary,
                    ),
                    title: Text(
                      syncState.isSyncing
                          ? 'Sincronizzazione in corso...'
                          : (syncState.lastSyncAt != null
                                ? 'Ultimo sync: ${_formatDate(syncState.lastSyncAt!)}'
                                : 'Mai sincronizzato'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      syncState.lastError ??
                          'Eventi acquisiti: ${syncState.lastPulledCount}',
                      style: TextStyle(
                        color: syncState.lastError != null
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        key: const Key('sync_now_button'),
                        icon: syncState.isSyncing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.sync_rounded),
                        label: Text(
                          syncState.isSyncing
                              ? 'Sincronizzazione...'
                              : 'Sincronizza ora',
                        ),
                        onPressed: syncState.isSyncing
                            ? null
                            : () async {
                                final summary = await ref
                                    .read(syncStateProvider.notifier)
                                    .triggerSync();
                                if (context.mounted && summary != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        summary.success
                                            ? 'Sincronizzazione completata: ${summary.eventsPulled} eventi incorporati.'
                                            : 'Errore di sincronizzazione: ${summary.errorMessage}',
                                      ),
                                    ),
                                  );
                                }
                              },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _padTwo(int n) => n.toString().padLeft(2, '0');

  static String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${_padTwo(local.day)}/${_padTwo(local.month)}/${local.year} ${_padTwo(local.hour)}:${_padTwo(local.minute)}:${_padTwo(local.second)}';
  }
}
