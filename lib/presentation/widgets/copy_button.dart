import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../app_copy.dart';

Future<void> copyToClipboard(
  BuildContext context,
  String text,
  AppCopy copy,
) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  await Clipboard.setData(ClipboardData(text: text));
  messenger?.showSnackBar(
    SnackBar(
      content: Text(
        copy.copiedToClipboard,
        style: AppTypography.ui(
          size: 14,
          weight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      backgroundColor: AppColors.pine,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}

/// Icon-only copy action used in the card headers.
class CopyButton extends StatelessWidget {
  const CopyButton({required this.text, required this.copy, super.key});

  final String text;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => copyToClipboard(context, text, copy),
      tooltip: copy.copyAction,
      icon: const Icon(Icons.content_copy_outlined, size: 17),
      color: AppColors.muted,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      padding: EdgeInsets.zero,
    );
  }
}

/// Labelled copy action used at the bottom of the reading sheet.
class CopyTextButton extends StatelessWidget {
  const CopyTextButton({required this.text, required this.copy, super.key});

  final String text;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => copyToClipboard(context, text, copy),
      icon: const Icon(Icons.content_copy_outlined, size: 17),
      label: Text(copy.copyAction),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.copperDark,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        textStyle: AppTypography.ui(size: 14, weight: FontWeight.w700),
      ),
    );
  }
}
