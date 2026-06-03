import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/issue_model.dart';
import '../providers/auth_provider.dart';
import '../providers/upvote_provider.dart';

/// Reusable animated upvote button.
/// Handles own-issue guard, optimistic updates, haptic feedback.
///
/// Usage:
///   UpvoteButton(issue: issue)                  // default size
///   UpvoteButton(issue: issue, compact: true)   // small — for cards
class UpvoteButton extends ConsumerWidget {
  final IssueModel issue;
  final bool compact;

  const UpvoteButton({
    super.key,
    required this.issue,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(userProfileProvider).valueOrNull?.id;
    final isOwnIssue = currentUserId == issue.userId;

    // Each issue gets its own provider instance via .family
    final params = UpvoteProviderParams(
      issueId: issue.id,
      issueOwnerId: issue.userId,
      initialCount: issue.upvotes,
    );
    final upvoteState = ref.watch(upvoteNotifierProvider(params));
    final notifier = ref.read(upvoteNotifierProvider(params).notifier);

    return _UpvoteButtonView(
      count: upvoteState.count,
      isVoted: upvoteState.isVoted,
      isLoading: upvoteState.isLoading,
      isOwnIssue: isOwnIssue,
      compact: compact,
      onTap: isOwnIssue
          ? null
          : () async {
              HapticFeedback.lightImpact();
              await notifier.toggle();
              // Show error snackbar if something went wrong
              if (upvoteState.error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Could not update vote. Try again.'),
                    backgroundColor: AppTheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
    );
  }
}

class _UpvoteButtonView extends StatefulWidget {
  final int count;
  final bool isVoted;
  final bool isLoading;
  final bool isOwnIssue;
  final bool compact;
  final VoidCallback? onTap;

  const _UpvoteButtonView({
    required this.count,
    required this.isVoted,
    required this.isLoading,
    required this.isOwnIssue,
    required this.compact,
    required this.onTap,
  });

  @override
  State<_UpvoteButtonView> createState() => _UpvoteButtonViewState();
}

class _UpvoteButtonViewState extends State<_UpvoteButtonView>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleCtrl;
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _animate() async {
    await _scaleCtrl.reverse();
    await _scaleCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final voted = widget.isVoted;
    final own = widget.isOwnIssue;

    // Colour scheme
    final activeColor = const Color(0xFF6366F1); // indigo
    final inactiveColor = AppTheme.textMuted;
    final iconColor = own
        ? AppTheme.border
        : voted
            ? activeColor
            : inactiveColor;
    final bgColor = voted ? activeColor.withOpacity(0.1) : Colors.transparent;

    if (widget.compact) {
      // ── Compact: small inline button for IssueCard ─────────
      return GestureDetector(
        onTap: () {
          if (widget.onTap != null) {
            _animate();
            widget.onTap!();
          }
        },
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: voted ? activeColor.withOpacity(0.4) : AppTheme.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.isLoading
                    ? SizedBox(
                        width: 11,
                        height: 11,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: activeColor,
                        ),
                      )
                    : Icon(
                        voted
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_upward_outlined,
                        size: 12,
                        color: iconColor,
                      ),
                const SizedBox(width: 3),
                Text(
                  '${widget.count}',
                  style: TextStyle(
                    color: voted ? activeColor : inactiveColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Full: detail screen button ─────────────────────────────
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          _animate();
          widget.onTap!();
        }
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: voted ? activeColor.withOpacity(0.1) : AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: voted ? activeColor.withOpacity(0.5) : AppTheme.border,
              width: voted ? 1.5 : 1,
            ),
            boxShadow: voted
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Arrow icon with animation
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: widget.isLoading
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: activeColor,
                        ),
                      )
                    : Icon(
                        key: ValueKey(voted),
                        voted
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_upward_outlined,
                        size: 18,
                        color: iconColor,
                      ),
              ),
              const SizedBox(width: 8),
              // Animated count
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.5),
                    end: Offset.zero,
                  ).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Text(
                  key: ValueKey(widget.count),
                  '${widget.count}',
                  style: TextStyle(
                    color: voted ? activeColor : AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                own
                    ? 'upvotes'
                    : voted
                        ? 'upvoted'
                        : 'upvote',
                style: TextStyle(
                  color: voted ? activeColor : inactiveColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Priority Badge ─────────────────────────────────────────────────────────────
// Used in admin views to signal urgency level based on upvote count.

class PriorityBadge extends StatelessWidget {
  final int upvotes;
  final bool small;

  const PriorityBadge({
    super.key,
    required this.upvotes,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final level = _priorityLevel(upvotes);
    if (level == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: level.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: level.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(level.emoji, style: TextStyle(fontSize: small ? 9 : 11)),
          SizedBox(width: small ? 2 : 4),
          Text(
            level.label,
            style: TextStyle(
              color: level.color,
              fontSize: small ? 9 : 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _PriorityLevel? _priorityLevel(int count) {
    if (count >= 20) {
      return _PriorityLevel(
        label: 'CRITICAL',
        emoji: '🔴',
        color: const Color(0xFFDC2626),
      );
    } else if (count >= 10) {
      return _PriorityLevel(
        label: 'HIGH',
        emoji: '🟠',
        color: const Color(0xFFEA580C),
      );
    } else if (count >= 5) {
      return _PriorityLevel(
        label: 'MEDIUM',
        emoji: '🟡',
        color: const Color(0xFFCA8A04),
      );
    } else if (count >= 1) {
      return _PriorityLevel(
        label: 'LOW',
        emoji: '🟢',
        color: const Color(0xFF16A34A),
      );
    }
    return null; // 0 upvotes → no badge
  }
}

class _PriorityLevel {
  final String label, emoji;
  final Color color;
  _PriorityLevel(
      {required this.label, required this.emoji, required this.color});
}
