import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/lectionary_models.dart';
import '../app_controller.dart';
import '../app_copy.dart';
import '../app_shell.dart';
import '../widgets/design_primitives.dart';
import '../widgets/sacred_mark.dart';

class LocSelectionScreen extends StatefulWidget {
  const LocSelectionScreen({required this.controller, super.key});

  final AppController controller;

  @override
  State<LocSelectionScreen> createState() => _LocSelectionScreenState();
}

class _LocSelectionScreenState extends State<LocSelectionScreen> {
  PrayerBook? selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final copy = copyFor(widget.controller);
        final books = widget.controller.booksForCurrentLanguage;
        selected ??= books.firstOrNull;
        if (selected != null &&
            !books.any((book) => book.code == selected!.code)) {
          selected = books.firstOrNull;
        }

        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SelectionHeader(
                          copy: copy,
                          controller: widget.controller,
                        ),
                        const SizedBox(height: 54),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 720;
                            if (isWide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: _SelectionIntro(copy: copy),
                                  ),
                                  const SizedBox(width: 74),
                                  Expanded(
                                    flex: 6,
                                    child: _BooksColumn(
                                      books: books,
                                      selected: selected,
                                      onSelect: (book) =>
                                          setState(() => selected = book),
                                      copy: copy,
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _SelectionIntro(copy: copy),
                                const SizedBox(height: 34),
                                _BooksColumn(
                                  books: books,
                                  selected: selected,
                                  onSelect: (book) =>
                                      setState(() => selected = book),
                                  copy: copy,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 36),
                        _SelectionFooter(
                          copy: copy,
                          onContinue: selected == null ? null : _continue,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _continue() async {
    final book = selected;
    if (book == null) return;
    await widget.controller.choosePrayerBook(book);
  }
}

class _SelectionHeader extends StatelessWidget {
  const _SelectionHeader({required this.copy, required this.controller});

  final AppCopy copy;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        return Row(
          children: [
            const SacredMark(size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.display(size: 27, height: .85),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    copy.brandSubline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.ui(
                      size: 9,
                      weight: FontWeight.w700,
                      color: AppColors.muted,
                      letterSpacing: 2.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            LanguageSwitcher(
              selected: controller.locale,
              onChanged: controller.setLanguage,
              compact: compact,
            ),
          ],
        );
      },
    );
  }
}

class _SelectionIntro extends StatelessWidget {
  const _SelectionIntro({required this.copy});

  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(copy.chooseEyebrow),
        const SizedBox(height: 17),
        Text(
          copy.chooseTitle,
          style: AppTypography.display(size: 54, height: .88),
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Text(
            copy.chooseSubtitle,
            style: AppTypography.ui(
              size: 17,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 34),
        Row(
          children: [
            Container(width: 44, height: 1, color: AppColors.copper),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                '“Lex orandi, lex credendi.”',
                style: AppTypography.display(
                  size: 18,
                  weight: FontWeight.w500,
                  color: AppColors.inkSoft,
                  style: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BooksColumn extends StatelessWidget {
  const _BooksColumn({
    required this.books,
    required this.selected,
    required this.onSelect,
    required this.copy,
  });

  final List<PrayerBook> books;
  final PrayerBook? selected;
  final ValueChanged<PrayerBook> onSelect;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return SurfaceCard(
        padding: const EdgeInsets.all(22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              color: AppColors.copperDark,
              size: 23,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                copy.noPrayerBooksForLanguage,
                style: AppTypography.ui(
                  size: 16,
                  color: AppColors.muted,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Eyebrow(copy.chooseLoc),
            const Spacer(),
            Text(
              '${books.length.toString().padLeft(2, '0')} opções',
              style: AppTypography.ui(size: 12, color: AppColors.mutedLight),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...books.map(
          (book) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _BookOption(
              book: book,
              selected: book.code == selected?.code,
              onTap: () => onSelect(book),
            ),
          ),
        ),
      ],
    );
  }
}

class _BookOption extends StatelessWidget {
  const _BookOption({
    required this.book,
    required this.selected,
    required this.onTap,
  });

  final PrayerBook book;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: book.fullName,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.pine
                : AppColors.cream.withValues(alpha: .75),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.pine : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.pine.withValues(alpha: .13),
                      blurRadius: 22,
                      offset: const Offset(0, 9),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              BookCover(book: book, width: 56, height: 76),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (book.recommended)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          'RECOMENDADO',
                          style: AppTypography.eyebrow(
                            color: selected
                                ? AppColors.copperWash
                                : AppColors.copperDark,
                            size: 9,
                          ),
                        ),
                      ),
                    Text(
                      book.name.isNotEmpty ? book.name : book.code,
                      style: AppTypography.display(
                        size: 24,
                        weight: FontWeight.w600,
                        color: selected ? AppColors.white : AppColors.ink,
                        height: 1,
                      ),
                    ),
                    if (book.jurisdiction.isNotEmpty || book.year != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        [
                          if (book.jurisdiction.isNotEmpty) book.jurisdiction,
                          if (book.year != null) '${book.year}',
                        ].join(' · '),
                        style: AppTypography.ui(
                          size: 12,
                          color: selected
                              ? AppColors.white.withValues(alpha: .7)
                              : AppColors.muted,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.copper : Colors.transparent,
                  border: Border.all(
                    color: selected ? AppColors.copper : AppColors.line,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 16, color: AppColors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionFooter extends StatelessWidget {
  const _SelectionFooter({required this.copy, required this.onContinue});

  final AppCopy copy;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final button = FilledButton.icon(
          onPressed: onContinue,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(copy.continueLabel),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.pine,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: AppTypography.ui(size: 14, weight: FontWeight.w700),
          ),
        );

        if (constraints.maxWidth < 620) {
          return Align(alignment: Alignment.centerRight, child: button);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [const Spacer(), button],
        );
      },
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
