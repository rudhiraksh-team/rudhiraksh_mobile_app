import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudhirakshapp/data/models/article_model.dart';
import 'package:rudhirakshapp/data/services/articles_service.dart';

class ArticlesController extends GetxController {
  var articles = <Article>[].obs;
  var isLoading = false.obs;
  var selectedArticle = Rxn<Article>();
  final commentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    isLoading.value = true;
    final result = await ArticlesService.fetchArticles();
    articles.value = result;
    isLoading.value = false;
  }

  Future<void> fetchArticleDetail(int id) async {
    final article = await ArticlesService.fetchArticle(id);
    if (article != null) {
      selectedArticle.value = article;
    }
  }

  Future<void> toggleLike(int articleId) async {
    final success = await ArticlesService.toggleLike(articleId);
    if (success) {
      // Update local state
      final index = articles.indexWhere((a) => a.id == articleId);
      if (index != -1) {
        await fetchArticles(); // Refresh to get updated counts
      }
    }
  }

  Future<bool> addComment(int articleId, String content, {int? parentCommentId}) async {
    if (content.trim().isEmpty) return false;
    final success = await ArticlesService.addComment(articleId, content, parentCommentId: parentCommentId);
    if (success) {
      commentController.clear();
      await fetchArticleDetail(articleId);
    }
    return success;
  }

  Future<bool> deleteComment(int articleId, int commentId) async {
    final success = await ArticlesService.deleteComment(articleId, commentId);
    if (success) {
      await fetchArticleDetail(articleId);
    }
    return success;
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
