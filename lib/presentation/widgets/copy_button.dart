import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../app_copy.dart';

/// Copy action for the card and sheet headers.
class CopyButton extends StatefulWidget {
  const CopyButton({required this.text, required this.copy, super.key});

  final String text;
  final AppCopy copy;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  static const _feedbackDuration = Duration(seconds: 2);

  bool justCopied = false;
  Timer? reset;

  @override
  void dispose() {
    reset?.cancel();
    super.dispose();
  }

  void _copy() {
    // The confirmation is not made to wait on the platform round trip.
    unawaited(Clipboard.setData(ClipboardData(text: widget.text)));
    unawaited(HapticFeedback.selectionClick());
    showCopiedConfirmation(context, widget.copy.copied);
    setState(() => justCopied = true);
    reset?.cancel();
    reset = Timer(_feedbackDuration, () {
      if (mounted) setState(() => justCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _copy,
      tooltip: justCopied ? widget.copy.copied : widget.copy.copyAction,
      icon: Icon(
        justCopied ? Icons.check_rounded : Icons.content_copy_outlined,
        size: 17,
      ),
      color: justCopied ? AppColors.pine : AppColors.muted,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      padding: EdgeInsets.zero,
    );
  }
}

/// Says the text was copied, over whatever is on screen.
///
/// It goes in the root overlay rather than through a ScaffoldMessenger: the
/// copy actions live inside modal sheets, and a snackbar belongs to the
/// Scaffold underneath them, where it is never seen.
void showCopiedConfirmation(BuildContext context, String message) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _CopiedConfirmation(
      message: message,
      onDismissed: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _CopiedConfirmation extends StatefulWidget {
  const _CopiedConfirmation({required this.message, required this.onDismissed});

  final String message;
  final VoidCallback onDismissed;

  @override
  State<_CopiedConfirmation> createState() => _CopiedConfirmationState();
}

class _CopiedConfirmationState extends State<_CopiedConfirmation>
    with SingleTickerProviderStateMixin {
  static const _visibleFor = Duration(milliseconds: 1500);

  late final AnimationController controller = AnimationController(
    duration: const Duration(milliseconds: 180),
    vsync: this,
  );
  Timer? hide;

  @override
  void initState() {
    super.initState();
    controller.forward();
    hide = Timer(_visibleFor, () async {
      if (!mounted) return;
      await controller.reverse();
      widget.onDismissed();
    });
  }

  @override
  void dispose() {
    hide?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    return Positioned(
      left: 20,
      right: 20,
      bottom: MediaQuery.viewPaddingOf(context).bottom + 26,
      child: IgnorePointer(
        child: Center(
          child: FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, .4),
                end: Offset.zero,
              ).animate(curve),
              child: Material(
                key: const ValueKey('copied-confirmation'),
                color: AppColors.pine,
                borderRadius: BorderRadius.circular(24),
                elevation: 6,
                shadowColor: AppColors.ink.withValues(alpha: .35),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 11, 18, 11),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: AppColors.copperWash,
                      ),
                      const SizedBox(width: 9),
                      Text(
                        widget.message,
                        style: AppTypography.ui(
                          size: 14,
                          weight: FontWeight.w600,
                          color: AppColors.white,
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
