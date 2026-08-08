import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'server_image.dart';

/// Quiz card, copied from the `Populaire Quizzen` grid on www.bijbelquiz.com.
///
/// ```html
/// <a class="group flex h-full flex-col">
///   <div class="relative aspect-16/9 w-full overflow-hidden rounded-md
///               bg-paper-sunken ring-1 ring-rule ring-inset">…</div>
///   <div class="mt-4 flex flex-1 flex-col">
///     <p class="text-[11px] font-medium uppercase tracking-[0.16em]
///               text-ink-muted">Oude Testament<span class="mx-2
///               text-rule-strong">/</span>Gemiddeld</p>
///     <h3 class="mt-2 font-display text-lg leading-snug text-ink">Spreuken</h3>
///     <p class="mt-2 line-clamp-2 pb-4 text-sm leading-relaxed
///               text-ink-muted">…</p>
///     <div class="mt-auto flex items-center justify-between border-t
///                 border-rule pt-3.5 text-xs text-ink-muted">
///       <span class="tabular-nums">15 vragen</span>
///       <span class="font-medium text-ink-soft">Start →</span>
///     </div>
///   </div>
/// </a>
/// ```
class QuizCard extends StatelessWidget {
  final String title;
  final String categoryName;
  final String imageUrl;
  final VoidCallback onTap;
  final String? difficulty;
  final String? description;
  final int? questionCount;
  final Widget? overlayBadge;

  const QuizCard({
    super.key,
    required this.title,
    required this.categoryName,
    required this.imageUrl,
    required this.onTap,
    this.difficulty,
    this.description,
    this.questionCount,
    this.overlayBadge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      splashColor: AppTheme.paperSunken,
      highlightColor: AppTheme.paperSunken,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // aspect-16/9 rounded-md bg-paper-sunken ring-1 ring-rule ring-inset
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppTheme.paperSunken,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.rule),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isNotEmpty)
                    ServerImage(imagePath: imageUrl)
                  else
                    const Center(
                      child: Icon(
                        Icons.menu_book_outlined,
                        size: 26,
                        color: AppTheme.inkMuted,
                      ),
                    ),
                  if (overlayBadge != null)
                    Positioned(left: 12, top: 12, child: overlayBadge!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Category / difficulty meta line.
          Text.rich(
            TextSpan(
              style: AppTheme.metaLabel,
              children: [
                TextSpan(text: categoryName.toUpperCase()),
                if (difficulty != null) ...[
                  const TextSpan(
                    text: '   /   ',
                    style: TextStyle(color: AppTheme.ruleStrong),
                  ),
                  TextSpan(text: difficulty!.toUpperCase()),
                ],
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTheme.displayTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: AppTheme.bodyMuted,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.rule)),
            ),
            padding: const EdgeInsets.only(top: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    questionCount != null ? '$questionCount vragen' : '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.caption,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Start',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.inkSoft,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward,
                  size: 12,
                  color: AppTheme.inkSoft,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
