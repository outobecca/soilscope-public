import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_log_provider.dart';
import '../../l10n/app_localizations.dart';

class EventNotificationOverlay extends ConsumerStatefulWidget {
  const EventNotificationOverlay({super.key});

  @override
  ConsumerState<EventNotificationOverlay> createState() =>
      _EventNotificationOverlayState();
}

class _EventNotificationOverlayState
    extends ConsumerState<EventNotificationOverlay>
    with SingleTickerProviderStateMixin {
  EventLogEntry? _currentEvent;
  Timer? _timer;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(eventLogProvider, (previous, next) {
      if (previous != null && next.length > previous.length) {
        setState(() {
          _currentEvent = next.first;
        });
        _timer?.cancel();
        _timer = Timer(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _currentEvent = null;
            });
          }
        });
      }
    });

    if (_currentEvent == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset = math.sin(_floatController.value * 2.0 * math.pi) * 8.0;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, (-20 * (1 - value)) + floatOffset),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: child,
        );
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.primaryContainer,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n != null ? _currentEvent!.getLocalizedMessage(l10n) : '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  color: theme.colorScheme.onPrimaryContainer,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() => _currentEvent = null);
                    _timer?.cancel();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
