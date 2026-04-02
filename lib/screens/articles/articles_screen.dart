import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/controllers/articles_controller.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/data/models/article_model.dart';
import 'article_detail_screen.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ArticlesController());
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Articles & Feed',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.articles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.articles.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  SolarLinearIcons.notebook,
                  size: 64,
                  color: colors.textSecondary.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No articles yet',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: colors.primaryColor,
          onRefresh: controller.fetchArticles,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: controller.articles.length,
            itemBuilder: (context, index) {
              return _ArticleCard(
                article: controller.articles[index],
                colors: colors,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArticleDetailScreen(
                        articleId: controller.articles[index].id,
                      ),
                    ),
                  );
                },
                onLike: () => controller.toggleLike(controller.articles[index].id),
              );
            },
          ),
        );
      }),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final AppThemeColors colors;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const _ArticleCard({
    required this.article,
    required this.colors,
    required this.onTap,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = article.createdAt != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(article.createdAt!))
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colors.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              SizedBox(
                height: 180,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: article.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _a) => Container(
                    color: AppColors.brandRed.withValues(alpha: 0.05),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, _a, _b) => Container(
                    color: AppColors.brandRed.withValues(alpha: 0.05),
                    child: Icon(
                      SolarLinearIcons.gallery,
                      size: 48,
                      color: colors.textSecondary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Content preview
                  Text(
                    article.content,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Bottom row: author, date, likes, comments
                  Row(
                    children: [
                      if (article.authorName != null) ...[
                        Icon(SolarLinearIcons.user, size: 14, color: colors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          article.authorName!,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (dateStr.isNotEmpty) ...[
                        Icon(SolarLinearIcons.calendar, size: 14, color: colors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: TextStyle(color: colors.textSecondary, fontSize: 12),
                        ),
                      ],
                      const Spacer(),
                      // Like button
                      GestureDetector(
                        onTap: onLike,
                        child: Row(
                          children: [
                            Icon(
                              article.isLikedByMe
                                  ? SolarBoldIcons.heart
                                  : SolarLinearIcons.heart,
                              size: 18,
                              color: article.isLikedByMe
                                  ? AppColors.brandRed
                                  : colors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${article.likesCount}',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Comments count
                      Row(
                        children: [
                          Icon(SolarLinearIcons.chatRound, size: 18, color: colors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${article.commentsCount}',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
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
