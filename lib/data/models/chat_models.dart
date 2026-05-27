// Chatbot models mirroring the /api/chatbot responses.

/// One turn in a conversation. [role] is the chat role ('user' | 'assistant'),
/// not a user account role. [provider] (assistant turns only) says which AI
/// tier answered: 'gemini' | 'groq' | 'rules'.
class ChatMessage {
  final String role;
  final String content;
  final String? provider;

  /// UI-only flags (not from the API): a placeholder bubble while awaiting a
  /// reply, and an error bubble when the request failed.
  final bool pending;
  final bool error;

  ChatMessage({
    required this.role,
    required this.content,
    this.provider,
    this.pending = false,
    this.error = false,
  });

  bool get isUser => role == 'user';

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role']?.toString() ?? 'assistant',
        content: json['content']?.toString() ?? '',
        provider: json['provider']?.toString(),
      );
}

/// Result of POST /chatbot/conversations/:id/messages.
class ChatReply {
  final int conversationId;
  final String reply;
  final String generatedBy;

  ChatReply({
    required this.conversationId,
    required this.reply,
    required this.generatedBy,
  });

  factory ChatReply.fromJson(Map<String, dynamic> json) => ChatReply(
        conversationId: (json['conversationId'] as num?)?.toInt() ?? 0,
        reply: json['reply']?.toString() ?? '',
        generatedBy: json['generatedBy']?.toString() ?? 'rules',
      );
}
