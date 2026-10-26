import 'package:flutter_test/flutter_test.dart';
import 'package:repetita/src/core/sync/hlc.dart';

void main() {
  group('Hlc', () {
    test('serializes and parses round-trip correctly', () {
      const hlc = Hlc(millis: 1792964340000, counter: 42, nodeId: 'dev_abc');
      final packed = hlc.pack();
      expect(packed, '001792964340000:00042:dev_abc');

      final parsed = Hlc.parse(packed);
      expect(parsed, equals(hlc));
      expect(parsed.millis, 1792964340000);
      expect(parsed.counter, 42);
      expect(parsed.nodeId, 'dev_abc');
    });

    test('lexicographical string ordering matches compareTo ordering', () {
      const h1 = Hlc(millis: 1000, counter: 0, nodeId: 'nodeA');
      const h2 = Hlc(millis: 1000, counter: 1, nodeId: 'nodeA');
      const h3 = Hlc(millis: 1001, counter: 0, nodeId: 'nodeA');
      const h4 = Hlc(millis: 1001, counter: 0, nodeId: 'nodeB');

      final list = [h4, h2, h3, h1];
      list.sort();

      expect(list, [h1, h2, h3, h4]);

      // Verify that packed string comparisons match exact mathematical ordering
      expect(h1.pack().compareTo(h2.pack()), lessThan(0));
      expect(h2.pack().compareTo(h3.pack()), lessThan(0));
      expect(h3.pack().compareTo(h4.pack()), lessThan(0));
    });

    test('send advances counter when wall clock is behind', () {
      final t1 = DateTime.utc(2026, 1, 1, 12, 0, 0);
      final hlc = Hlc.initial('nodeA', t1);

      // Same wall time -> counter increments
      final sent1 = hlc.send(t1);
      expect(sent1.millis, t1.millisecondsSinceEpoch);
      expect(sent1.counter, 1);

      // Earlier wall time -> millis stays, counter increments
      final earlier = t1.subtract(const Duration(minutes: 5));
      final sent2 = sent1.send(earlier);
      expect(sent2.millis, t1.millisecondsSinceEpoch);
      expect(sent2.counter, 2);

      // Later wall time -> millis updates, counter resets to 0
      final later = t1.add(const Duration(seconds: 1));
      final sent3 = sent2.send(later);
      expect(sent3.millis, later.millisecondsSinceEpoch);
      expect(sent3.counter, 0);
    });

    test('receive guarantees strict causality (local > remote)', () {
      const local = Hlc(millis: 5000, counter: 2, nodeId: 'localNode');
      const remote = Hlc(millis: 6000, counter: 0, nodeId: 'remoteNode');

      // Local receives remote with higher millis
      final wall = DateTime.fromMillisecondsSinceEpoch(5500, isUtc: true);
      final received = local.receive(remote, wall);

      expect(received.millis, 6000);
      expect(received.counter, 1);
      expect(received > remote, isTrue);
      expect(received > local, isTrue);
    });

    test('drift guard prevents clock sabotage', () {
      const local = Hlc(millis: 1000, counter: 0, nodeId: 'nodeA');
      // Remote claims to be 1 year in the future
      const remote = Hlc(
        millis: 1000 + 365 * 24 * 3600 * 1000,
        counter: 5,
        nodeId: 'nodeB',
      );

      final wall = DateTime.fromMillisecondsSinceEpoch(1000, isUtc: true);
      final received = local.receive(remote, wall);

      // Clamped to wall + maxDriftMs (60s)
      expect(received.millis, 1000 + Hlc.maxDriftMs);
    });
  });
}
