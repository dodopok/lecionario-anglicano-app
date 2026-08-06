import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../app_copy.dart';

/// Icon-only copy action used in the card headers.
class CopyButton extends StatelessWidget {
  const CopyButton({required this.text, required this.copy, super.key});

  final String text;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return _CopyAction(text: text, copy: copy, labelled: false);
  }
}

/// Labelled copy action used at the bottom of the reading sheet.
class CopyTextButton extends StatelessWidget {
  const CopyTextButton({required this.text, required this.copy, super.key});

  final String text;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return _CopyAction(text: text, copy: copy, labelled: true);
  }
}

/// Confirms the copy on the button itself.
///
/// A snackbar would be hidden behind the sheets these buttons live in, so the
/// control answers where the finger already is.
class _CopyAction extends StatefulWidget {
  const _CopyAction({
    required this.text,
    required this.copy,
    required this.labelled,
  });

  final String text;
  final AppCopy copy;
  final bool labelled;

  @override
  State<_CopyAction> createState() => _CopyActionState();
}

class _CopyActionState extends State<_CopyAction> {
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
    setState(() => justCopied = true);
    reset?.cancel();
    reset = Timer(_feedbackDuration, () {
      if (mounted) setState(() => justCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = justCopied ? widget.copy.copied : widget.copy.copyAction;
    final icon = Icon(
      justCopied ? Icons.check_rounded : Icons.content_copy_outlined,
      size: 17,
    );

    if (!widget.labelled) {
      return IconButton(
        onPressed: _copy,
        tooltip: label,
        icon: icon,
        color: justCopied ? AppColors.pine : AppColors.muted,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        padding: EdgeInsets.zero,
      );
    }

    return TextButton.icon(
      onPressed: _copy,
      icon: icon,
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: justCopied ? AppColors.pine : AppColors.copperDark,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        textStyle: AppTypography.ui(size: 14, weight: FontWeight.w700),
      ),
    );
  }
}
