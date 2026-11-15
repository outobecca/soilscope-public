import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  HoverInfo info(
    String title, {
    required bool pinned,
    String? sourceId,
    void Function()? onDismiss,
  }) {
    return HoverInfo(
      title: title,
      description: '',
      isPinned: pinned,
      sourceId: sourceId,
      onDismiss: onDismiss,
    );
  }

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  test('pinned info is the animation pause signal', () async {
    final notifier = container.read(uIStateProvider.notifier);

    expect(container.read(inspectionPausedProvider), isFalse);

    notifier.setHoverInfo(info('SUN', pinned: true));
    await flush();

    expect(container.read(uIStateProvider)?.isPinned, isTrue);
    expect(container.read(inspectionPausedProvider), isTrue);

    notifier.setHoverInfo(info('SUN HOVER', pinned: false));
    await flush();

    // Hover updates cannot replace a pinned inspection.
    expect(container.read(uIStateProvider)?.title, 'SUN');

    notifier.setHoverInfo(null);
    await flush();

    expect(container.read(inspectionPausedProvider), isFalse);
  });

  test('dismissing a pinned card releases the visual selection', () async {
    final notifier = container.read(uIStateProvider.notifier);
    var dismissed = 0;

    notifier.setHoverInfo(
      info(
        'ROOT',
        pinned: true,
        sourceId: 'root-1',
        onDismiss: () {
          dismissed++;
        },
      ),
    );
    await flush();
    expect(container.read(uIStateProvider)?.title, 'ROOT');

    notifier.setHoverInfo(null);
    await flush();

    expect(dismissed, 1);
  });

  test('replacing a pinned card dismisses its previous owner', () async {
    final notifier = container.read(uIStateProvider.notifier);
    var firstDismissed = 0;
    var secondDismissed = 0;

    notifier.setHoverInfo(
      info(
        'SUN',
        pinned: true,
        sourceId: 'sun',
        onDismiss: () {
          firstDismissed++;
        },
      ),
    );
    await flush();

    notifier.setHoverInfo(
      info(
        'ROOT',
        pinned: true,
        sourceId: 'root',
        onDismiss: () {
          secondDismissed++;
        },
      ),
    );
    await flush();

    expect(firstDismissed, 1);
    expect(secondDismissed, 0);
    expect(container.read(uIStateProvider)?.title, 'ROOT');
  });

  test('refreshing the same pinned source does not dismiss it', () async {
    final notifier = container.read(uIStateProvider.notifier);
    var dismissed = 0;

    notifier.setHoverInfo(
      info(
        'PARTICLE',
        pinned: true,
        sourceId: 'particle-7',
        onDismiss: () {
          dismissed++;
        },
      ),
    );
    await flush();

    notifier.setHoverInfo(
      info(
        'PARTICLE',
        pinned: true,
        sourceId: 'particle-7',
        onDismiss: () {
          dismissed++;
        },
      ),
    );
    await flush();

    expect(dismissed, 0);
  });

  test(
    'a stale hover exit does not dismiss a pinned card from elsewhere',
    () async {
      final notifier = container.read(uIStateProvider.notifier);
      var dismissed = 0;

      notifier.setHoverInfo(
        info(
          'LEAF',
          pinned: true,
          sourceId: 'inspection-leaf',
          onDismiss: () {
            dismissed++;
          },
        ),
      );
      await flush();

      notifier.clearUnpinnedHover();
      await flush();

      expect(container.read(uIStateProvider)?.title, 'LEAF');
      expect(dismissed, 0);
    },
  );

  test('a hover exit clears an unpinned card', () async {
    final notifier = container.read(uIStateProvider.notifier);

    notifier.setHoverInfo(info('SUN', pinned: false));
    await flush();
    expect(container.read(uIStateProvider)?.title, 'SUN');

    notifier.clearUnpinnedHover();
    await flush();

    expect(container.read(uIStateProvider), isNull);
  });

  test('a hover exit cancels a hover still waiting to be published', () async {
    final notifier = container.read(uIStateProvider.notifier);

    notifier.setHoverInfo(info('SUN', pinned: false));
    notifier.clearUnpinnedHover();
    await flush();

    expect(container.read(uIStateProvider), isNull);
  });
}
