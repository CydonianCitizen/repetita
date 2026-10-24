import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/algorithms/image_occlusion/image_occlusion_box.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../media/presentation/widgets/media_image_widget.dart';
import 'controllers/card_list_controller.dart';
import 'widgets/occlusion_canvas_painter.dart';

class ImageOcclusionEditorScreen extends ConsumerStatefulWidget {
  const ImageOcclusionEditorScreen({
    super.key,
    required this.deckId,
    required this.mediaReference,
    this.initialBoxes,
    this.initialBackNotes,
  });

  final int deckId;
  final String mediaReference;
  final List<ImageOcclusionBox>? initialBoxes;
  final String? initialBackNotes;

  @override
  ConsumerState<ImageOcclusionEditorScreen> createState() =>
      _ImageOcclusionEditorScreenState();
}

class _ImageOcclusionEditorScreenState
    extends ConsumerState<ImageOcclusionEditorScreen> {
  late final List<ImageOcclusionBox> _boxes;
  String? _selectedBoxId;
  Offset? _dragStart;
  Rect? _currentDragRect;
  late final TextEditingController _labelController;
  late final TextEditingController _notesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _boxes = List.of(widget.initialBoxes ?? []);
    _labelController = TextEditingController();
    _notesController = TextEditingController(text: widget.initialBackNotes);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _dragStart = details.localPosition;
      _currentDragRect = Rect.fromPoints(_dragStart!, _dragStart!);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragStart == null) return;
    setState(() {
      _currentDragRect = Rect.fromPoints(_dragStart!, details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details, Size canvasSize) {
    if (_dragStart == null || _currentDragRect == null) return;

    final rect = _currentDragRect!;
    final left = math.min(rect.left, rect.right);
    final top = math.min(rect.top, rect.bottom);
    final width = rect.width.abs();
    final height = rect.height.abs();

    setState(() {
      _dragStart = null;
      _currentDragRect = null;
    });

    // Ignore tiny micro-drags
    if (width < 12 ||
        height < 12 ||
        canvasSize.width <= 0 ||
        canvasSize.height <= 0) {
      return;
    }

    final relX = (left / canvasSize.width).clamp(0.0, 1.0);
    final relY = (top / canvasSize.height).clamp(0.0, 1.0);
    final relW = (width / canvasSize.width).clamp(0.0, 1.0 - relX);
    final relH = (height / canvasSize.height).clamp(0.0, 1.0 - relY);

    final newId = 'io_${DateTime.now().microsecondsSinceEpoch}';
    final newBox = ImageOcclusionBox(
      id: newId,
      x: relX,
      y: relY,
      width: relW,
      height: relH,
    );

    setState(() {
      _boxes.add(newBox);
      _selectedBoxId = newId;
      _labelController.text = '';
    });
  }

  void _onTapCanvas(TapUpDetails details, Size canvasSize) {
    if (canvasSize.width <= 0 || canvasSize.height <= 0) return;

    final clickX = details.localPosition.dx / canvasSize.width;
    final clickY = details.localPosition.dy / canvasSize.height;

    // Search in reverse order (top-most box first)
    ImageOcclusionBox? hit;
    for (int i = _boxes.length - 1; i >= 0; i--) {
      final b = _boxes[i];
      if (clickX >= b.x &&
          clickX <= b.x + b.width &&
          clickY >= b.y &&
          clickY <= b.y + b.height) {
        hit = b;
        break;
      }
    }

    setState(() {
      if (hit != null) {
        _selectedBoxId = hit.id;
        _labelController.text = hit.label ?? '';
      } else {
        _selectedBoxId = null;
        _labelController.text = '';
      }
    });
  }

  void _updateSelectedLabel(String value) {
    if (_selectedBoxId == null) return;
    final idx = _boxes.indexWhere((b) => b.id == _selectedBoxId);
    if (idx != -1) {
      setState(() {
        _boxes[idx] = _boxes[idx].copyWith(label: value.trim());
      });
    }
  }

  void _deleteSelectedBox() {
    if (_selectedBoxId == null) return;
    setState(() {
      _boxes.removeWhere((b) => b.id == _selectedBoxId);
      _selectedBoxId = null;
      _labelController.text = '';
    });
  }

  void _undoLastBox() {
    if (_boxes.isEmpty) return;
    setState(() {
      _boxes.removeLast();
      _selectedBoxId = null;
      _labelController.text = '';
    });
  }

  Future<void> _saveCards() async {
    final l10n = AppLocalizations.of(context);
    if (_boxes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.drawOcclusionPrompt ?? 'Please create at least one mask',
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(cardListControllerProvider(widget.deckId).notifier)
          .createImageOcclusionCards(
            mediaReference: widget.mediaReference,
            boxes: _boxes,
            backNotes: _notesController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.cardSaved ?? 'Image occlusion cards saved'),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.errorSavingCard(e.toString()) ?? 'Failed to save cards: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final count = _boxes.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.imageOcclusionEditorTitle ?? 'Image Occlusion Editor',
        ),
        actions: [
          IconButton(
            key: const Key('undo_occlusion_button'),
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: _boxes.isNotEmpty ? _undoLastBox : null,
          ),
          IconButton(
            key: const Key('clear_occlusion_button'),
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear all',
            onPressed: _boxes.isNotEmpty
                ? () {
                    setState(() {
                      _boxes.clear();
                      _selectedBoxId = null;
                      _labelController.text = '';
                    });
                  }
                : null,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Instruction header banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: Row(
                children: [
                  Icon(
                    Icons.gesture_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n?.drawOcclusionPrompt ??
                          'Drag on image to create mask rectangles',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: colorScheme.primaryContainer,
                    label: Text(
                      l10n?.occlusionCount(count) ?? '$count cards',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Canvas & image interactive area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return AspectRatio(
                        aspectRatio: 1.0, // Default bounding box
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background image
                              MediaImageWidget(
                                mediaReference: widget.mediaReference,
                                fit: BoxFit.contain,
                                enableZoom: false,
                              ),

                              // Gesture detector & paint overlay
                              Positioned.fill(
                                child: LayoutBuilder(
                                  builder: (context, boxConstraints) {
                                    final canvasSize = Size(
                                      boxConstraints.maxWidth,
                                      boxConstraints.maxHeight,
                                    );
                                    return GestureDetector(
                                      key: const Key(
                                        'occlusion_canvas_gesture_detector',
                                      ),
                                      behavior: HitTestBehavior.opaque,
                                      onPanStart: _onPanStart,
                                      onPanUpdate: _onPanUpdate,
                                      onPanEnd: (d) => _onPanEnd(d, canvasSize),
                                      onTapUp: (d) =>
                                          _onTapCanvas(d, canvasSize),
                                      child: CustomPaint(
                                        painter: OcclusionCanvasPainter(
                                          boxes: _boxes,
                                          selectedBoxId: _selectedBoxId,
                                          currentDragRect: _currentDragRect,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bottom drawer: Selected box settings & extra notes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedBoxId != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('occlusion_label_field'),
                            controller: _labelController,
                            decoration: InputDecoration(
                              labelText:
                                  l10n?.maskLabelHint ??
                                  'Mask label / answer (optional)',
                              isDense: true,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: _updateSelectedLabel,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          key: const Key('delete_selected_box_button'),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          tooltip: l10n?.deleteOcclusionBox ?? 'Delete mask',
                          onPressed: _deleteSelectedBox,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          key: const Key('save_occlusion_cards_button'),
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check),
                          label: Text(
                            l10n?.saveOcclusionCards ?? 'Save Cards ($count)',
                          ),
                          onPressed: (_isSaving || _boxes.isEmpty)
                              ? null
                              : _saveCards,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
