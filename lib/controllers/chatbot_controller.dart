import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rudhirakshapp/data/models/chat_models.dart';
import 'package:rudhirakshapp/data/services/chatbot_service.dart';

class ChatbotController extends GetxController {
  final GetStorage _storage = GetStorage();

  /// Persisted active thread id, so the conversation survives app restarts.
  static const String _convKey = 'chat_conversation_id';

  final messages = <ChatMessage>[].obs;
  final isSending = false.obs;
  final isRestoring = false.obs;

  int? conversationId;

  String get role => _storage.read<String>('userRole') ?? 'patient';

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  /// Reload the persisted conversation (if any). A stored id that no longer
  /// resolves (e.g. after switching accounts) is dropped silently.
  Future<void> _restore() async {
    final stored = _storage.read(_convKey);
    final id = (stored is int) ? stored : int.tryParse('$stored');
    if (id == null) return;
    isRestoring.value = true;
    try {
      final msgs = await ChatbotService.fetchMessages(id);
      if (msgs.isEmpty) {
        await _storage.remove(_convKey);
        return;
      }
      conversationId = id;
      messages.assignAll(msgs);
    } finally {
      isRestoring.value = false;
    }
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isSending.value) return;

    messages.add(ChatMessage(role: 'user', content: trimmed));
    messages.add(ChatMessage(role: 'assistant', content: '', pending: true));
    isSending.value = true;

    try {
      // Create the thread lazily on the first message.
      conversationId ??= await ChatbotService.createConversation();
      if (conversationId == null) throw Exception('could not create conversation');
      await _storage.write(_convKey, conversationId);

      final reply = await ChatbotService.sendMessage(conversationId!, trimmed);
      if (reply == null) throw Exception('no reply');

      messages[messages.length - 1] = ChatMessage(
        role: 'assistant',
        content: reply.reply,
        provider: reply.generatedBy,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('chatbot send error: $e');
      messages[messages.length - 1] = ChatMessage(
        role: 'assistant',
        content: "Sorry, I couldn't reach the assistant. Please try again.",
        error: true,
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<void> newChat() async {
    conversationId = null;
    messages.clear();
    await _storage.remove(_convKey);
  }
}
