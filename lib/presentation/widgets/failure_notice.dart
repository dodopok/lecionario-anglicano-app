import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/services/load_failure.dart';
import '../app_copy.dart';
import 'design_primitives.dart';

/// Says why there is no lectionary on screen, and offers to ask again.
///
/// The app keeps no copy of the lectionary, so a failed request leaves nothing
/// to read: silence would look like a day with no readings.
class FailureNotice extends StatelessWidget {
  const FailureNotice({
    required this.failure,
    required this.copy,
    required this.onRetry,
    this.compact = false,
    super.key,
  });

  final LoadFailure failure;
  final AppCopy copy;
  final VoidCallback onRetry;

  /// Sits alongside content instead of standing in for it.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final offline = failure.isOffline;
    final title = offline ? copy.offlineTitle : copy.serverErrorTitle;
    final body = offline ? copy.offlineBody : copy.serverErrorBody;
    final icon = offline
        ? Icons.cloud_off_outlined
        : Icons.error_outline_rounded;

    return SurfaceCard(
      key: const ValueKey('failure-notice'),
      padding: EdgeInsets.all(compact ? 16 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: compact ? 20 : 24, color: AppColors.copperDark),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.display(
                    size: compact ? 21 : 25,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 10),
          Text(
            body,
            style: AppTypography.ui(
              size: compact ? 13.5 : 15,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
          SizedBox(height: compact ? 12 : 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              key: const ValueKey('failure-retry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(copy.retry),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.pine,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: AppTypography.ui(size: 14, weight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
