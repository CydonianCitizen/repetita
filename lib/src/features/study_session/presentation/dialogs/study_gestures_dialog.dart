import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/study_gesture_config.dart';
import '../controllers/study_gesture_controller.dart';

class StudyGesturesDialog extends ConsumerWidget {
  const StudyGesturesDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const StudyGesturesDialog(),
    );
  }

  Widget _buildActionSelector({
    required BuildContext context,
    required String label,
    required IconData icon,
    required StudyGestureAction currentAction,
    required ValueChanged<StudyGestureAction> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DropdownButton<StudyGestureAction>(
            value: currentAction,
            isDense: true,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(12),
            items: StudyGestureAction.values.map((action) {
              return DropdownMenuItem(
                value: action,
                child: Text(
                  action.displayName,
                  style: theme.textTheme.bodySmall,
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(studyGestureControllerProvider);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.gesture_rounded, size: 22),
          SizedBox(width: 8),
          Text('Gesti Touch Studio'),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Abilita gesti touch'),
                subtitle: const Text('Scorri o tocca due volte per interagire'),
                value: config.enableGestures,
                onChanged: (_) {
                  ref.read(studyGestureControllerProvider.notifier).toggleEnabled();
                },
              ),
              const Divider(),
              if (config.enableGestures) ...[
                const SizedBox(height: 8),
                _buildActionSelector(
                  context: context,
                  label: 'Swipe Sinistra',
                  icon: Icons.swipe_left_rounded,
                  currentAction: config.swipeLeft,
                  onChanged: (a) => ref
                      .read(studyGestureControllerProvider.notifier)
                      .updateAction(swipeLeft: a),
                ),
                _buildActionSelector(
                  context: context,
                  label: 'Swipe Destra',
                  icon: Icons.swipe_right_rounded,
                  currentAction: config.swipeRight,
                  onChanged: (a) => ref
                      .read(studyGestureControllerProvider.notifier)
                      .updateAction(swipeRight: a),
                ),
                _buildActionSelector(
                  context: context,
                  label: 'Swipe Verso l\'Alto',
                  icon: Icons.swipe_up_rounded,
                  currentAction: config.swipeUp,
                  onChanged: (a) => ref
                      .read(studyGestureControllerProvider.notifier)
                      .updateAction(swipeUp: a),
                ),
                _buildActionSelector(
                  context: context,
                  label: 'Swipe Verso il Basso',
                  icon: Icons.swipe_down_rounded,
                  currentAction: config.swipeDown,
                  onChanged: (a) => ref
                      .read(studyGestureControllerProvider.notifier)
                      .updateAction(swipeDown: a),
                ),
                _buildActionSelector(
                  context: context,
                  label: 'Doppio Tocco',
                  icon: Icons.touch_app_rounded,
                  currentAction: config.doubleTap,
                  onChanged: (a) => ref
                      .read(studyGestureControllerProvider.notifier)
                      .updateAction(doubleTap: a),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref
                .read(studyGestureControllerProvider.notifier)
                .setConfig(const StudyGestureConfig());
          },
          child: const Text('Predefiniti'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Chiudi'),
        ),
      ],
    );
  }
}
