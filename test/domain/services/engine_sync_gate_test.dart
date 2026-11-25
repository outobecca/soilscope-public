import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/default_simulation_profile.dart';
import 'package:soilscope/domain/services/simulation_runtime.dart';

void main() {
  BiophysicalState stateAt(int i) => BiophysicalState(
    profile: defaultSoilProfile(),
    plants: [seedPlant()],
    timeElapsed: i.toDouble(),
    isRunning: true,
  );

  group('EngineSyncGate', () {
    test('sends the first update immediately and coalesces the rest', () {
      final gate = EngineSyncGate();
      final sent = <BiophysicalState>[];

      for (var i = 0; i < 60; i++) {
        final toSend = gate.request(stateAt(i));
        if (toSend != null) sent.add(toSend);
      }

      // One push for the whole burst, carrying the first value.
      expect(sent, hasLength(1));
      expect(sent.single.timeElapsed, 0);

      // The tick flushes the latest value, so the engine converges without
      // having to replay every intermediate edit.
      final flushed = gate.onEngineFrame();
      expect(flushed, isNotNull);
      expect(flushed!.timeElapsed, 59);
    });

    test('the next burst after a frame sends immediately again', () {
      final gate = EngineSyncGate();

      expect(gate.request(stateAt(1)), isNotNull);
      expect(gate.request(stateAt(2)), isNull);
      expect(gate.onEngineFrame()!.timeElapsed, 2);

      expect(gate.request(stateAt(3)), isNotNull);
    });

    test('reset drops a pending update', () {
      final gate = EngineSyncGate();

      expect(gate.request(stateAt(1)), isNotNull);
      expect(gate.request(stateAt(2)), isNull);
      gate.reset();

      expect(gate.onEngineFrame(), isNull);
      expect(gate.request(stateAt(3)), isNotNull);
    });
  });
}
