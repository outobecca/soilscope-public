import 'package:flutter_test/flutter_test.dart';

import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/default_simulation_profile.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';
import 'package:soilscope/presentation/screens/logic_lab/logic_lab_context.dart';

BiophysicalState _state() => BiophysicalState(
  profile: defaultSoilProfile(),
  plants: const [],
  timeElapsed: 0,
);

HoverInfo _info({
  required String title,
  required String sourceId,
  String? layerId,
  String? logicLabModel,
  bool isAtmosphere = false,
}) => HoverInfo(
  title: title,
  description: 'Hotspot description',
  sourceId: sourceId,
  layerId: layerId,
  logicLabModel: logicLabModel,
  isAtmosphere: isAtmosphere,
  stats: const {'Value': '12.4', 'Unit': 'mg/kg'},
);

void main() {
  final state = _state();

  test('water hotspot selects the water-retention model and its layer', () {
    final context = LogicLabLaunchContext.fromHoverInfo(
      info: _info(
        title: 'SENSOR - W',
        sourceId: 'hotspot-B1-W-123',
        layerId: 'B1',
        logicLabModel: 'waterRetention',
      ),
      state: state,
    );

    expect(context.process, LogicLabProcess.waterRetention);
    expect(context.layerId, 'B1');
    expect(context.link, LogicLabSimulationLink.waterContent);
    expect(context.stats['Value'], '12.4');
  });

  test('nitrification process keeps the selected layer context', () {
    final context = LogicLabLaunchContext.fromHoverInfo(
      info: _info(title: 'NITRIFICATION', sourceId: 'process-nitrification-42'),
      state: state,
      selectedLayerId: 'B1',
    );

    expect(context.process, LogicLabProcess.nitrification);
    expect(context.layerId, 'B1');
    expect(context.link, LogicLabSimulationLink.ammonium);
  });

  test('redox hotspot at the atmosphere has no soil layer', () {
    final context = LogicLabLaunchContext.fromHoverInfo(
      info: _info(title: 'REDOX POTENTIAL', sourceId: 'redox-gradient'),
      state: state,
      selectedLayerId: 'atmosphere',
    );

    expect(context.process, LogicLabProcess.redox);
    expect(context.layerId, isNull);
    expect(context.isAtmosphere, isTrue);
    expect(context.link, LogicLabSimulationLink.redoxPotential);
  });

  test('photosynthesis hotspot selects the Farquhar model', () {
    final context = LogicLabLaunchContext.fromHoverInfo(
      info: _info(
        title: 'PHOTOSYNTHESIS',
        sourceId: 'photosynthesis-indicator',
      ),
      state: state,
    );

    expect(context.process, LogicLabProcess.photosynthesis);
    expect(context.link, LogicLabSimulationLink.solarRadiation);
  });

  test('leaf inspection is located in the atmosphere', () {
    final context = LogicLabLaunchContext.fromHoverInfo(
      info: _info(
        title: 'PLANT CANOPY',
        sourceId: 'inspection-leaf',
        isAtmosphere: true,
      ),
      state: state,
    );

    expect(context.process, LogicLabProcess.photosynthesis);
    expect(context.isAtmosphere, isTrue);
  });

  test('root inspection selects diffusion and the topsoil fallback', () {
    final context = LogicLabLaunchContext.fromHoverInfo(
      info: _info(title: 'ROOT TISSUE', sourceId: 'inspection-root'),
      state: state,
    );

    expect(context.process, LogicLabProcess.diffusion);
    expect(context.layerId, isNull);
    expect(context.link, LogicLabSimulationLink.organicNitrogen);
  });

  test('an unknown hotspot falls back to the nitrification model', () {
    final context = LogicLabLaunchContext.fromHoverInfo(
      info: _info(title: 'DATA PACKET', sourceId: 'data-packet-17'),
      state: state,
    );

    expect(context.process, LogicLabProcess.nitrification);
  });
}
