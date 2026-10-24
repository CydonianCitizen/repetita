import '../../../core/services/file_picker_service.dart';
import '../../../core/database/app_database.dart' show MediaData;

import 'package:flutter/material.dart';

import '../../media/presentation/widgets/media_image_widget.dart';
import '../../media/utils/media_content_renderer.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/algorithms/cloze/cloze_parser.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/utils/text_direction_utils.dart';
import '../../tags/data/tags_dao.dart';
import '../../../core/database/database_provider.dart';
import '../../tags/domain/tag_entity.dart';
import '../../tags/presentation/controllers/tags_controller.dart';
import '../../media/data/services/audio_service.dart';
import 'controllers/card_list_controller.dart';
import 'dialogs/audio_recorder_dialog.dart';
import 'image_occlusion_editor_screen.dart';
import 'widgets/audio_player_chip.dart';
import 'widgets/card_content_renderer.dart';

class CardEditorScreen extends ConsumerStatefulWidget {
  const CardEditorScreen({
    super.key,
    required this.deckId,
    this.cardId,
    this.initialFront,
    this.initialBack,
  });

  final int deckId;
  final int? cardId;
  final String? initialFront;
  final String? initialBack;

  bool get isEditing => cardId != null;

  @override
  ConsumerState<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends ConsumerState<CardEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _frontController;
  late final TextEditingController _backController;
  final List<TagEntity> _selectedTags = [];
  final Set<int> _initialTagIds = {};
  bool _tagsLoaded = false;
  bool _isSaving = false;
  bool _isReverseCard = false;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(text: widget.initialFront);
    _backController = TextEditingController(text: widget.initialBack);
    if (widget.isEditing) {
      _loadExistingTags();
    }
  }

  Future<void> _loadExistingTags() async {
    final tagsDao = ref.read(tagsDaoProvider);
    final tags = await tagsDao.getTagsForCard(widget.cardId!);
    if (mounted) {
      setState(() {
        final entities = tags.map((t) => t.toEntity()).toList();
        _selectedTags.addAll(entities);
        _initialTagIds.addAll(entities.map((t) => t.id));
        _tagsLoaded = true;
      });
    }
  }

  bool get _hasChanges {
    final frontInitial = widget.initialFront ?? '';
    final backInitial = widget.initialBack ?? '';
    if (_frontController.text != frontInitial) return true;
    if (_backController.text != backInitial) return true;
    if (_isReverseCard) return true;
    if (widget.isEditing) {
      if (!_tagsLoaded) return false;
      final currentTagIds = _selectedTags.map((t) => t.id).toSet();
      if (currentTagIds.length != _initialTagIds.length ||
          !currentTagIds.containsAll(_initialTagIds)) {
        return true;
      }
    } else {
      if (_selectedTags.isNotEmpty) return true;
    }
    return false;
  }

  Future<bool> _showDiscardConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.discardChangesTitle ?? 'Discard changes?'),
        content: Text(
          l10n?.discardChangesMessage ?? 'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            key: const Key('confirm_discard_button'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n?.discard ?? 'Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  void _insertCloze() {
    final text = _frontController.text;
    final selection = _frontController.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;
    final nextIdx = ClozeParser.getNextClozeIndex(text);
    final newText = ClozeParser.wrapSelectionWithCloze(
      text,
      start,
      end,
      index: nextIdx,
    );

    final selectedLength = end - start;
    final newCursorOffset = selectedLength > 0
        ? start + newText.length - text.length
        : start + '{{c$nextIdx::'.length;

    _frontController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }

  Future<MediaData?> _pickAndSaveImage() async {
    final picker = ref.read(filePickerServiceProvider);
    final picked = await picker.pickImage();
    if (picked == null) return null;
    final bytes = await picked.readBytes();
    if (bytes.isEmpty) return null;

    final mediaService = ref.read(mediaServiceProvider);
    return mediaService.saveImageBytes(bytes, originalFileName: picked.name);
  }

  Future<void> _pickAndInsertImage(TextEditingController controller) async {
    final media = await _pickAndSaveImage();
    if (media == null) return;

    final insertTag = '![alt](media://${media.fileName})';
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final newText = text.replaceRange(start, end, insertTag);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + insertTag.length),
    );
  }

  Widget _buildImageThumbnails(TextEditingController controller) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final fileNames = MediaContentRenderer.extractMediaFilenames(
          value.text,
        );
        if (fileNames.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: fileNames.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final name = fileNames[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: MediaImageWidget(
                          mediaReference: name,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () {
                          final text = controller.text;
                          final stripped = text
                              .replaceAll(
                                RegExp(
                                  r'!\[.*?\]\(media:\/\/' +
                                      RegExp.escape(name) +
                                      r'\)',
                                ),
                                '',
                              )
                              .replaceAll('media://$name', '')
                              .trim();
                          controller.value = TextEditingValue(
                            text: stripped,
                            selection: TextSelection.collapsed(
                              offset: stripped.length,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAudioChips(TextEditingController controller) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final soundTags = AudioService.extractSoundTags(value.text);
        if (soundTags.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: soundTags.map((sound) {
              return AudioPlayerChip(
                key: ValueKey('audio_chip_$sound'),
                audioReference: sound,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _recordAndInsertAudio(TextEditingController controller) async {
    final soundTag = await AudioRecorderDialog.show(context);
    if (soundTag != null && soundTag.isNotEmpty) {
      final currentText = controller.text;
      final separator = currentText.isNotEmpty && !currentText.endsWith('\n')
          ? '\n'
          : '';
      controller.text = '$currentText$separator$soundTag';
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
      setState(() {});
    }
  }

  Future<void> _openImageOcclusionEditor() async {
    final media = await _pickAndSaveImage();
    if (media == null || !mounted) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ImageOcclusionEditorScreen(
          deckId: widget.deckId,
          mediaReference: media.fileName,
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showAddTagDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final textController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final allTagsAsync = ref.watch(tagsControllerProvider);
            final allTags = allTagsAsync.value ?? [];

            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: Text(l10n?.selectTags ?? 'Select Tags'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                key: const Key('new_tag_field'),
                                controller: textController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText:
                                      l10n?.newTagHint ?? 'Enter tag name...',
                                  isDense: true,
                                  border: const OutlineInputBorder(),
                                ),
                                onSubmitted: (value) async {
                                  final name = value.trim();
                                  if (name.isNotEmpty) {
                                    final tagId = await ref
                                        .read(tagsControllerProvider.notifier)
                                        .createTag(name);
                                    final newTag = TagEntity(
                                      id: tagId,
                                      name: name,
                                      createdAt: DateTime.now().toUtc(),
                                    );
                                    if (!_selectedTags.any(
                                      (t) => t.id == tagId,
                                    )) {
                                      setState(() => _selectedTags.add(newTag));
                                    }
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              key: const Key('confirm_add_tag_button'),
                              tooltip: l10n?.addTag ?? 'Add Tag',
                              icon: const Icon(Icons.add),
                              onPressed: () async {
                                final name = textController.text.trim();
                                if (name.isNotEmpty) {
                                  final tagId = await ref
                                      .read(tagsControllerProvider.notifier)
                                      .createTag(name);
                                  final newTag = TagEntity(
                                    id: tagId,
                                    name: name,
                                    createdAt: DateTime.now().toUtc(),
                                  );
                                  if (!_selectedTags.any(
                                    (t) => t.id == tagId,
                                  )) {
                                    setState(() => _selectedTags.add(newTag));
                                  }
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                        if (allTags.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            l10n?.tags ?? 'Tags',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 180),
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: allTags.map((tag) {
                                  final isSelected = _selectedTags.any(
                                    (t) => t.id == tag.id,
                                  );
                                  return FilterChip(
                                    label: Text(tag.name),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setDialogState(() {
                                        if (selected) {
                                          if (!_selectedTags.any(
                                            (t) => t.id == tag.id,
                                          )) {
                                            _selectedTags.add(tag);
                                          }
                                        } else {
                                          _selectedTags.removeWhere(
                                            (t) => t.id == tag.id,
                                          );
                                        }
                                      });
                                      setState(() {});
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        MaterialLocalizations.of(context).okButtonLabel,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _save({bool addAnother = false}) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      final front = _frontController.text.trim();
      final back = _backController.text.trim();
      final tagIds = _selectedTags.map((t) => t.id).toList();

      if (widget.isEditing) {
        await ref
            .read(cardListControllerProvider(widget.deckId).notifier)
            .updateCard(
              id: widget.cardId!,
              front: front,
              back: back,
              tagIds: tagIds,
            );
      } else {
        final indices = ClozeParser.extractClozeIndices(front);
        if (indices.length > 1) {
          await ref
              .read(cardListControllerProvider(widget.deckId).notifier)
              .createClozeCards(
                front: front,
                back: back,
                clozeIndices: indices,
                tagIds: tagIds,
              );
        } else if (_isReverseCard && indices.isEmpty) {
          await ref
              .read(cardListControllerProvider(widget.deckId).notifier)
              .createReversedCard(front: front, back: back, tagIds: tagIds);
        } else {
          await ref
              .read(cardListControllerProvider(widget.deckId).notifier)
              .createCard(
                front: front,
                back: back,
                clozeIndex: indices.firstOrNull,
                tagIds: tagIds,
              );
        }
      }

      if (mounted) {
        if (addAnother) {
          _frontController.clear();
          _backController.clear();
          _selectedTags.clear();
          _initialTagIds.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.cardSaved ?? 'Card saved',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.errorSavingCard(e.toString()) ?? 'Failed to save card: $e',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showPreview(BuildContext context) {
    final front = _frontController.text.trim();
    final back = _backController.text.trim();
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.visibility_outlined, size: 20),
            const SizedBox(width: 8),
            Text(l10n?.cardPreviewTitle ?? 'Card Preview'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n?.previewFront ?? 'FRONT',
                  style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(ctx).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                CardContentRenderer(
                  content: front.isEmpty
                      ? (l10n?.emptyField ?? '(Empty)')
                      : front,
                  textStyle: Theme.of(ctx).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  l10n?.previewBack ?? 'BACK',
                  style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(ctx).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 6),
                CardContentRenderer(
                  content: back.isEmpty
                      ? (l10n?.emptyField ?? '(Empty)')
                      : back,
                  textStyle: Theme.of(ctx).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.close ?? 'Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final title = widget.isEditing
        ? (l10n?.editCard ?? 'Edit Card')
        : (l10n?.newCard ?? 'New Card');

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): () {
          if (!_isSaving) _save(addAnother: false);
        },
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): () {
          if (!_isSaving) _save(addAnother: false);
        },
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
          if (!_isSaving) _save(addAnother: false);
        },
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true): () {
          if (!_isSaving) _save(addAnother: false);
        },
      },
      child: PopScope(
        canPop: !_hasChanges || _isSaving,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldDiscard = await _showDiscardConfirmation(context);
          if (shouldDiscard && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                key: const Key('preview_card_button'),
                icon: const Icon(Icons.visibility_outlined),
                tooltip:
                    l10n?.previewMathMarkdownTooltip ??
                    'Preview Math & Markdown',
                onPressed: () => _showPreview(context),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _frontController,
                        builder: (context, value, _) {
                          return TextFormField(
                            key: const Key('card_front_field'),
                            controller: _frontController,
                            textDirection: TextDirectionUtils.getDirection(
                              value.text,
                            ),
                            autofocus: !widget.isEditing,
                            maxLines: 5,
                            minLines: 3,
                            decoration: InputDecoration(
                              labelText: l10n?.cardFront ?? 'Front (Prompt)',
                              hintText:
                                  l10n?.promptHint ??
                                  'Enter question or prompt...',
                              alignLabelWithHint: true,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return l10n?.frontPromptCannotBeEmpty ??
                                    'Front prompt cannot be empty';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ActionChip(
                            key: const Key('insert_cloze_button'),
                            avatar: const Icon(
                              Icons.data_array_rounded,
                              size: 16,
                            ),
                            label: Text(l10n?.insertCloze ?? 'Cloze [...]'),
                            tooltip:
                                l10n?.insertClozeTooltip ??
                                'Wrap selection with Cloze deletion',
                            onPressed: _insertCloze,
                          ),
                          ActionChip(
                            key: const Key('insert_image_button'),
                            avatar: const Icon(Icons.image_outlined, size: 16),
                            label: Text(l10n?.insertImage ?? 'Image'),
                            tooltip: l10n?.insertImage ?? 'Insert Image',
                            onPressed: () =>
                                _pickAndInsertImage(_frontController),
                          ),
                          ActionChip(
                            key: const Key('record_audio_button'),
                            avatar: const Icon(Icons.mic_outlined, size: 16),
                            label: Text(l10n?.recordAudioTitle ?? 'Audio'),
                            tooltip:
                                l10n?.recordMicTooltip ?? 'Record audio note',
                            onPressed: () =>
                                _recordAndInsertAudio(_frontController),
                          ),
                          ActionChip(
                            key: const Key('image_occlusion_button'),
                            avatar: const Icon(Icons.crop_rounded, size: 16),
                            label: Text(
                              l10n?.imageOcclusion ?? 'Image Occlusion',
                            ),
                            tooltip:
                                l10n?.imageOcclusionSubtitle ??
                                'Create cards by covering parts of an image',
                            onPressed: _openImageOcclusionEditor,
                          ),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _frontController,
                            builder: (context, value, _) {
                              final isCloze = ClozeParser.isCloze(value.text);
                              if (!isCloze) return const SizedBox.shrink();
                              final count = ClozeParser.extractClozeIndices(
                                value.text,
                              ).length;
                              return Chip(
                                visualDensity: VisualDensity.compact,
                                backgroundColor: colorScheme.primaryContainer,
                                label: Text(
                                  '$count Cloze',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      _buildImageThumbnails(_frontController),
                      _buildAudioChips(_frontController),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _backController,
                        builder: (context, backVal, _) {
                          return ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _frontController,
                            builder: (context, frontVal, _) {
                              final isCloze = ClozeParser.isCloze(
                                frontVal.text,
                              );
                              return TextFormField(
                                key: const Key('card_back_field'),
                                controller: _backController,
                                textDirection: TextDirectionUtils.getDirection(
                                  backVal.text,
                                ),
                                maxLines: 5,
                                minLines: 3,
                                decoration: InputDecoration(
                                  labelText: isCloze
                                      ? (l10n?.cardBackNotes ??
                                            'Back (Extra Notes, Optional)')
                                      : (l10n?.cardBack ?? 'Back (Answer)'),
                                  hintText: isCloze
                                      ? (l10n?.cardBackNotes ??
                                            'Optional notes or explanation...')
                                      : (l10n?.answerHint ?? 'Enter answer...'),
                                  alignLabelWithHint: true,
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (val) {
                                  if (!isCloze) {
                                    if (val == null || val.trim().isEmpty) {
                                      return l10n?.backAnswerCannotBeEmpty ??
                                          'Back answer cannot be empty';
                                    }
                                  }
                                  return null;
                                },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ActionChip(
                            key: const Key('insert_image_back_button'),
                            avatar: const Icon(Icons.image_outlined, size: 16),
                            label: Text(l10n?.insertImage ?? 'Image'),
                            tooltip: l10n?.insertImage ?? 'Insert Image',
                            onPressed: () =>
                                _pickAndInsertImage(_backController),
                          ),
                          const SizedBox(width: 8),
                          ActionChip(
                            key: const Key('record_audio_back_button'),
                            avatar: const Icon(Icons.mic_outlined, size: 16),
                            label: Text(l10n?.recordAudioTitle ?? 'Audio'),
                            tooltip:
                                l10n?.recordMicTooltip ?? 'Record audio note',
                            onPressed: () =>
                                _recordAndInsertAudio(_backController),
                          ),
                        ],
                      ),
                      _buildImageThumbnails(_backController),
                      _buildAudioChips(_backController),
                      if (!widget.isEditing) ...[
                        const SizedBox(height: 12),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _frontController,
                          builder: (context, value, _) {
                            final isCloze = ClozeParser.isCloze(value.text);
                            return SwitchListTile.adaptive(
                              key: const Key('reverse_card_switch'),
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                l10n?.generateReverseCard ??
                                    'Generate reverse card (Front ↔ Back)',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                l10n?.generateReverseCardSubtitle ?? 'Creates two connected cards swapping prompt and answer',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              value: isCloze ? false : _isReverseCard,
                              onChanged: isCloze
                                  ? null
                                  : (val) =>
                                        setState(() => _isReverseCard = val),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(
                            Icons.label_outline_rounded,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n?.tags ?? 'Tags',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ..._selectedTags.map(
                            (tag) => InputChip(
                              key: Key('tag_chip_${tag.id}'),
                              label: Text(tag.name),
                              onDeleted: () {
                                setState(() {
                                  _selectedTags.removeWhere(
                                    (t) => t.id == tag.id,
                                  );
                                });
                              },
                            ),
                          ),
                          ActionChip(
                            key: const Key('add_tag_button'),
                            avatar: const Icon(Icons.add, size: 16),
                            label: Text(l10n?.addTag ?? 'Add Tag'),
                            onPressed: () => _showAddTagDialog(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Center(
                heightFactor: 1.0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Row(
                    children: [
                      if (!widget.isEditing) ...[
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('save_and_add_another_button'),
                            onPressed: _isSaving
                                ? null
                                : () => _save(addAnother: true),
                            child: Text(
                              l10n?.saveAndAddAnother ?? 'Save & Add Another',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: FilledButton(
                          key: const Key('save_card_button'),
                          onPressed: _isSaving
                              ? null
                              : () => _save(addAnother: false),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n?.save ?? 'Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
