import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudhirakshapp/controllers/chatbot_controller.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/data/models/chat_models.dart';

/// Role-aware AI assistant chat. The reply grounding is decided server-side
/// by the caller's role; this screen only renders the conversation.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatbotController controller = Get.put(ChatbotController());
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _welcome() {
    switch (controller.role) {
      case 'doctor':
        return "Hi Doctor. Ask me about your patients — overdue transfusions, low hemoglobin, or a specific case (e.g. \"summarize patient 42\"). This is decision-support, not a diagnosis.";
      case 'patient':
        return "Hi! I'm your care assistant. Ask me about your transfusions, hemoglobin, upcoming visits, or anything about thalassemia. I can only see your own records — always confirm decisions with your care team.";
      default:
        return "Hi! Ask me about patient management in your blood bank — overdue transfusions, low-Hb counts, or a specific patient by id (e.g. \"summarize patient 42\").";
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    _textController.clear();
    controller.send(text);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: colors.surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: colors.primaryColor, size: 22),
            const SizedBox(width: 8),
            Text(
              'AI Assistant',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'New chat',
            icon: Icon(Icons.add_comment_outlined, color: colors.textSecondary),
            onPressed: () {
              controller.newChat();
              _textController.clear();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final msgs = controller.messages;
              _scrollToBottom();
              if (msgs.isEmpty) {
                return ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _MessageBubble(
                      message: ChatMessage(role: 'assistant', content: _welcome()),
                      colors: colors,
                    ),
                  ],
                );
              }
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: msgs.length,
                itemBuilder: (context, i) =>
                    _MessageBubble(message: msgs[i], colors: colors),
              );
            }),
          ),
          _Composer(
            colors: colors,
            textController: _textController,
            controller: controller,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final AppThemeColors colors;

  const _MessageBubble({required this.message, required this.colors});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bubbleColor = isUser
        ? colors.primaryColor
        : (message.error
            ? colors.errorColor.withValues(alpha: 0.12)
            : colors.surfaceColor);
    final textColor = isUser ? Colors.white : colors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: message.error
                  ? colors.errorColor.withValues(alpha: 0.15)
                  : colors.primaryColor.withValues(alpha: 0.12),
              child: Icon(
                message.error ? Icons.error_outline : Icons.auto_awesome,
                size: 15,
                color: message.error ? colors.errorColor : colors.primaryColor,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: colors.borderColor),
                  ),
                  child: message.pending
                      ? _TypingIndicator(color: colors.textSecondary)
                      : Text(
                          message.content,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                ),
                if (!isUser && message.provider != null && !message.pending)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      message.provider!,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final Color color;
  const _TypingIndicator({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          ),
          const SizedBox(width: 8),
          Text('Thinking…', style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final AppThemeColors colors;
  final TextEditingController textController;
  final ChatbotController controller;
  final VoidCallback onSend;

  const _Composer({
    required this.colors,
    required this.textController,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceColor,
        border: Border(top: BorderSide(color: colors.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      style: TextStyle(color: colors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ask the assistant…',
                        hintStyle: TextStyle(color: colors.textSecondary),
                        filled: true,
                        fillColor: colors.backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: colors.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: colors.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                              BorderSide(color: colors.primaryColor, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(
                    () => Material(
                      color: colors.primaryColor,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: controller.isSending.value ? null : onSend,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.send_rounded,
                            color: Colors.white.withValues(
                                alpha: controller.isSending.value ? 0.5 : 1),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'AI-generated for informational support only. Not a medical diagnosis — confirm with a clinician.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary, fontSize: 10, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
