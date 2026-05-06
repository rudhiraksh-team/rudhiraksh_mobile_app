class Article {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final bool isPublished;
  final bool isGlobal;
  final int? tenantId;
  final int createdById;
  final String? authorName;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByMe;
  final List<ArticleComment> comments;
  final String? createdAt;
  final String? updatedAt;

  Article({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.isPublished = true,
    this.isGlobal = false,
    this.tenantId,
    required this.createdById,
    this.authorName,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLikedByMe = false,
    this.comments = const [],
    this.createdAt,
    this.updatedAt,
  });

  Article copyWith({
    int? likesCount,
    bool? isLikedByMe,
  }) {
    return Article(
      id: id,
      title: title,
      content: content,
      imageUrl: imageUrl,
      isPublished: isPublished,
      isGlobal: isGlobal,
      tenantId: tenantId,
      createdById: createdById,
      authorName: authorName,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      comments: comments,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'],
      isPublished: json['isPublished'] ?? json['is_published'] ?? true,
      isGlobal: json['isGlobal'] ?? json['is_global'] ?? false,
      tenantId: json['tenantId'] ?? json['tenant_id'],
      createdById: json['createdById'] ?? json['created_by_id'] ?? 0,
      authorName: json['authorName'] ?? json['author_name'] ?? json['author']?['name'],
      likesCount: json['likesCount'] ?? json['likes_count'] ?? json['_count']?['likes'] ?? 0,
      commentsCount: json['commentsCount'] ?? json['comments_count'] ?? json['_count']?['comments'] ?? 0,
      isLikedByMe: json['isLikedByMe'] ?? json['is_liked_by_me'] ?? false,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((c) => ArticleComment.fromJson(c))
              .toList() ??
          [],
      createdAt: json['createdAt'] ?? json['created_at'],
      updatedAt: json['updatedAt'] ?? json['updated_at'],
    );
  }
}

class ArticleComment {
  final int id;
  final String content;
  final int articleId;
  final int userId;
  final String? userName;
  final int? parentCommentId;
  final List<ArticleComment> replies;
  final String? createdAt;
  final String? deletedAt;

  ArticleComment({
    required this.id,
    required this.content,
    required this.articleId,
    required this.userId,
    this.userName,
    this.parentCommentId,
    this.replies = const [],
    this.createdAt,
    this.deletedAt,
  });

  factory ArticleComment.fromJson(Map<String, dynamic> json) {
    return ArticleComment(
      id: json['id'],
      content: json['content'] ?? '',
      articleId: json['articleId'] ?? json['article_id'] ?? 0,
      userId: json['userId'] ?? json['user_id'] ?? 0,
      userName: json['userName'] ?? json['user_name'] ?? json['user']?['name'],
      parentCommentId: json['parentCommentId'] ?? json['parent_comment_id'],
      replies: (json['replies'] as List<dynamic>?)
              ?.map((r) => ArticleComment.fromJson(r))
              .toList() ??
          [],
      createdAt: json['createdAt'] ?? json['created_at'],
      deletedAt: json['deletedAt'] ?? json['deleted_at'],
    );
  }
}
