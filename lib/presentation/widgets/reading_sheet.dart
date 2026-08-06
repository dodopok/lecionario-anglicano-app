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

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        key: const ValueKey('reading-sheet'),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy.readingLabel(reading.kind),
                    style: AppTypography.display(size: 27, height: 1.05),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reading.reference,
                    style: AppTypography.ui(
                      size: 15,
                      weight: FontWeight.w700,
                      color: AppColors.copperDark,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
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
                    if (translation != null && translation.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        translation,
                        style: AppTypography.ui(
                          size: 12,
                          color: AppColors.muted,
                        ),
                      ),
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
                  CopyTextButton(
                    key: const ValueKey('copy-reading'),
                    copy: copy,
                    text: readingAsText(reading, copy),
                  ),
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
