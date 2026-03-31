import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/controllers/articles_controller.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/data/models/article_model.dart';

class ArticleDetailScreen extends StatefulWidget {
  final int articleId;
  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  @override
  void initState() {
    super.initState();
    final controller = Get.find<ArticlesController>();
    controller.fetchArticleDetail(widget.articleId);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticlesController>();
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: Obx(() {
        final article = controller.selectedArticle.value;
        if (article == null || article.id != widget.articleId) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            // App Bar with image
            SliverAppBar(
              expandedHeight: article.imageUrl != null ? 250 : 0,
              pinned: true,
              backgroundColor: colors.surfaceColor,
              flexibleSpace: article.imageUrl != null
                  ? FlexibleSpaceBar(
                      background: CachedNetworkImage(
                        imageUrl: article.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : null,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      article.title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Meta row
                    Row(
                      children: [
                        if (article.authorName != null) ...[
                          Icon(SolarLinearIcons.user, size: 16, color: colors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            article.authorName!,
                            style: TextStyle(color: colors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (article.createdAt != null) ...[
                          Icon(SolarLinearIcons.calendar, size: 16, color: colors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(DateTime.parse(article.createdAt!)),
                            style: TextStyle(color: colors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Like + comment count
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => controller.toggleLike(article.id),
                          child: Row(
                            children: [
                              Icon(
                                article.isLikedByMe ? SolarBoldIcons.heart : SolarLinearIcons.heart,
                                color: article.isLikedByMe ? AppColors.brandRed : colors.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text('${article.likesCount}', style: TextStyle(color: colors.textSecondary)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Icon(SolarLinearIcons.chatRound, size: 20, color: colors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${article.comments.length}', style: TextStyle(color: colors.textSecondary)),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Divider(color: colors.dividerColor),
                    const SizedBox(height: 16),

                    // Content
                    Text(
                      article.content,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        height: 1.7,
                      ),
                    ),

                    const SizedBox(height: 24),
                    Divider(color: colors.dividerColor),
                    const SizedBox(height: 16),

                    // Comments section
                    Text(
                      'Comments',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (article.comments.isEmpty)
                      Text(
                        'No comments yet. Be the first!',
                        style: TextStyle(color: colors.textSecondary, fontSize: 14),
                      ),

                    ...article.comments.map((c) => _CommentTile(
                      comment: c,
                      colors: colors,
                      articleId: article.id,
                    )),

                    const SizedBox(height: 80), // Space for input
                  ],
                ),
              ),
            ),
          ],
        );
      }),

      // Comment input
      bottomSheet: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 8,
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 8,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceColor,
          border: Border(top: BorderSide(color: colors.dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.commentController,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  hintStyle: TextStyle(color: colors.textSecondary),
                  border: InputBorder.none,
                  filled: false,
                ),
                style: TextStyle(color: colors.textPrimary),
                maxLines: 1,
              ),
            ),
            IconButton(
              onPressed: () async {
                final text = controller.commentController.text.trim();
                if (text.isNotEmpty) {
                  await controller.addComment(widget.articleId, text);
                }
              },
              icon: Icon(SolarBoldIcons.plain2, color: AppColors.brandRed, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final ArticleComment comment;
  final AppThemeColors colors;
  final int articleId;

  const _CommentTile({
    required this.comment,
    required this.colors,
    required this.articleId,
  });

  @override
  Widget build(BuildContext context) {
    if (comment.deletedAt != null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(SolarLinearIcons.userCircle, size: 18, color: colors.textSecondary),
              const SizedBox(width: 6),
              Text(
                comment.userName ?? 'User',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (comment.createdAt != null)
                Text(
                  DateFormat('dd MMM').format(DateTime.parse(comment.createdAt!)),
                  style: TextStyle(color: colors.textSecondary, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            comment.content,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          // Nested replies
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Column(
                children: comment.replies
                    .map((r) => _CommentTile(comment: r, colors: colors, articleId: articleId))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
