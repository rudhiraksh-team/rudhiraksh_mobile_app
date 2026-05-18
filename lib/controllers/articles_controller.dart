import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudhirakshapp/data/models/article_model.dart';
import 'package:rudhirakshapp/data/services/articles_service.dart';

class ArticlesController extends GetxController {
  var articles = <Article>[].obs;
  var isLoading = false.obs;
  var error = RxnString();
  var selectedArticle = Rxn<Article>();
  final commentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    isLoading.value = true;
    error.value = null;
    final result = await ArticlesService.fetchArticles();
    articles.value = result.articles;
    error.value = result.error;
    isLoading.value = false;
  }

  Future<void> fetchArticleDetail(int id) async {
    final article = await ArticlesService.fetchArticle(id);
    if (article != null) {
      selectedArticle.value = article;
    }
  }

  Future<void> toggleLike(int articleId) async {
    final index = articles.indexWhere((a) => a.id == articleId);
    final originalListItem = index == -1 ? null : articles[index];
    final originalSelected = selectedArticle.value?.id == articleId
        ? selectedArticle.value
        : null;

    // Need at least one source of truth to flip from. The detail screen
    // can be opened deep-linked before the list has loaded, in which case
    // `selectedArticle` is the only thing we have.
    final source = originalSelected ?? originalListItem;
    if (source == null) return;

    final liked = !source.isLikedByMe;
    final newCount = source.likesCount + (liked ? 1 : -1);

    // Optimistic toggle on every view bound to this article so the heart
    // fills the moment the user taps — list card, detail screen, both.
    if (originalListItem != null) {
      articles[index] = originalListItem.copyWith(
        isLikedByMe: liked,
        likesCount: originalListItem.likesCount + (liked ? 1 : -1),
      );
    }
    if (originalSelected != null) {
      selectedArticle.value = originalSelected.copyWith(
        isLikedByMe: liked,
        likesCount: newCount,
      );
    }

    final success = await ArticlesService.toggleLike(articleId);
    if (!success) {
      // Roll back; the server didn't accept it.
      if (originalListItem != null) articles[index] = originalListItem;
      if (originalSelected != null) selectedArticle.value = originalSelected;
      return;
    }
    // Re-sync with the server so any other state (e.g., another user's
    // concurrent like) is reflected accurately.
    await fetchArticles();
    if (originalSelected != null) {
      await fetchArticleDetail(articleId);
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
