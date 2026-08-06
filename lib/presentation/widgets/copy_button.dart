import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../app_copy.dart';

/// Copy action for the card and sheet headers.
///
/// It confirms on the button itself: a snackbar would be hidden behind the
/// sheets these buttons live in, so the control answers where the finger
/// already is.
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
