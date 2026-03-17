import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/paper_dao.dart';
import 'drive_auth_client.dart';
import 'drive_service.dart';
import 'drive_sync_service.dart';

final driveServiceProvider = Provider<DriveService>((ref) {
  final client = DriveAuthClient();
  return DriveService(client);
});

final driveSyncServiceProvider = Provider<DriveSyncService>((ref) {
  return DriveSyncService(
    driveService: ref.watch(driveServiceProvider),
    paperDao: PaperDao(),
  );
});

final syncStateProvider =
    NotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);

class SyncNotifier extends Notifier<SyncState> {
  @override
  SyncState build() => const SyncState();

  Future<void> sync() async {
    state = const SyncState(status: SyncStatus.syncing, message: 'Syncing...');
    final syncService = ref.read(driveSyncServiceProvider);
    state = await syncService.sync();
  }
}
