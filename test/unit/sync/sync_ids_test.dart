import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/sync/sync_ids.dart';

void main() {
  group('SyncIds', () {
    test(
      'uuidV7 produces valid RFC 9562 format and is monotonically sorted',
      () {
        final t1 = DateTime.utc(2026, 1, 1, 10, 0, 0);
        final t2 = DateTime.utc(2026, 1, 1, 10, 0, 1);

        final id1 = SyncIds.uuidV7(t1);
        final id2 = SyncIds.uuidV7(t2);

        expect(id1.length, 36);
        expect(id1[14], '7'); // version 7
        expect(
          ['8', '9', 'a', 'b'].contains(id1[19].toLowerCase()),
          isTrue,
        ); // variant 1

        // Monotonic ordering by timestamp
        expect(id1.compareTo(id2), lessThan(0));
      },
    );

    test('uuidV5 produces deterministic UUID for same namespace and name', () {
      const ns =
          '6ba7b810-9dad-11d1-80b4-00c04fd430c8'; // DNS namespace RFC 4122
      final idA = SyncIds.uuidV5(ns, 'card_42');
      final idB = SyncIds.uuidV5(ns, 'card_42');
      final idC = SyncIds.uuidV5(ns, 'card_43');

      expect(idA, equals(idB));
      expect(idA, isNot(equals(idC)));
      expect(idA[14], '5'); // version 5
      expect(['8', '9', 'a', 'b'].contains(idA[19].toLowerCase()), isTrue);
    });

    test('generateDeviceId produces 16 hex characters', () {
      final devId = SyncIds.generateDeviceId();
      expect(devId.length, 16);
      expect(RegExp(r'^[0-9a-f]{16}$').hasMatch(devId), isTrue);
    });
  });
}
