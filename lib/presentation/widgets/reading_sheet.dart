import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/lectionary_models.dart';
import '../app_copy.dart';
import 'copy_button.dart';

/// Full reading, opened from the readings card.
///
/// A sheet rather than a dialog: scripture is long and this is read on a phone.
class ReadingSheet extends StatelessWidget {
  const ReadingSheet({required this.reading, required this.copy, super.key});

  final Reading reading;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    final verses = reading.content?.verses ?? const <ReadingVerse>[];
    final text = reading.text?.trim();
    final translation = reading.translation?.trim();

    // Draggable, so the reading can be pushed away from wherever the thumb
    // happens to be instead of only from the handle at the top.
    return DraggableScrollableSheet(
      key: const ValueKey('reading-sheet'),
      expand: false,
      initialChildSize: .78,
      minChildSize: .4,
      maxChildSize: .95,
      shouldCloseOnMinExtent: true,
      builder: (context, scrollController) => SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          copy.readingLabel(reading.kind),
                          style: AppTypography.display(size: 27, height: 1.05),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 8,
                          runSpacing: 5,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              reading.reference,
                              style: AppTypography.ui(
                                size: 15,
                                weight: FontWeight.w700,
                                color: AppColors.copperDark,
                              ),
                            ),
                            if (translation != null && translation.isNotEmpty)
                              _TranslationTag(translation),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  CopyButton(
                    key: const ValueKey('copy-reading'),
                    copy: copy,
                    text: readingAsText(reading, copy),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (text != null && text.isNotEmpty)
                      Text(
                        text,
                        style: AppTypography.display(
                          size: 21,
                          weight: FontWeight.w500,
                          color: AppColors.inkSoft,
                          height: 1.32,
                        ),
                      ),
                    if (verses.isNotEmpty) ...[
                      if (text != null && text.isNotEmpty)
                        const SizedBox(height: 16),
                      ...verses.map((verse) => _VerseBlock(verse: verse)),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.line.withValues(alpha: .8)),
                ),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.inkSoft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      textStyle: AppTypography.ui(
                        size: 14,
                        weight: FontWeight.w700,
                      ),
                    ),
                    child: Text(copy.close),
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

String readingAsText(Reading reading, AppCopy copy) {
  final buffer = StringBuffer()
    ..writeln('${copy.readingLabel(reading.kind)} — ${reading.reference}')
    ..writeln();
  final text = reading.text?.trim();
  if (text != null && text.isNotEmpty) buffer.writeln(text);
  for (final verse in reading.content?.verses ?? const <ReadingVerse>[]) {
    buffer.writeln(
      verse.number == null ? verse.text : '${verse.number} ${verse.text}',
    );
  }
  return buffer.toString().trimRight();
}

/// The Bible version the API served this reading in.
class _TranslationTag extends StatelessWidget {
  const _TranslationTag(this.translation);

  final String translation;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('reading-translation'),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.copperWash.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        translation.toUpperCase(),
        style: AppTypography.ui(
          size: 10,
          weight: FontWeight.w700,
          color: AppColors.copperDark,
          letterSpacing: .8,
        ),
      ),
    );
  }
}

class _VerseBlock extends StatelessWidget {
  const _VerseBlock({required this.verse});

  final ReadingVerse verse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text.rich(
        TextSpan(
          children: [
            if (verse.number != null)
              TextSpan(
                text: '${verse.number} ',
                style: AppTypography.ui(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.copperDark,
                ),
              ),
            TextSpan(
              text: verse.text,
              style: AppTypography.display(
                size: 20,
                weight: FontWeight.w500,
                color: AppColors.inkSoft,
                height: 1.32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
