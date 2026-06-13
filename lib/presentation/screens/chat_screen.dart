import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/providers.dart';
import '../../domain/models/chat_message.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isAILoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? textOverride]) async {
    final text = textOverride ?? _messageController.text.trim();
    if (text.isEmpty) return;

    if (textOverride == null) {
      _messageController.clear();
    }

    setState(() {
      _isAILoading = true;
    });

    // Send user message
    await ref.read(chatProvider.notifier).sendMessage(text);

    setState(() {
      _isAILoading = false;
    });

    // Scroll to bottom
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final chatMessages = ref.watch(chatProvider);

    // Auto-scroll to bottom on load
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Prompt Chips for Students
    final List<String> quickQueries = [
      "I feel exhausted.",
      "My mock scores are bad.",
      "My parents expect too much.",
      "How to fix backlog stress?"
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversational Mentor',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Offline empathetic feedback based on physical metrics and exam load.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    ref.read(chatProvider.notifier).clearChat();
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear Chat', style: TextStyle(fontSize: 12)),
                )
              ],
            ),
          ),

          // Message Thread List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatMessages.length + (_isAILoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Check if thinking indicator is active at the bottom
                    if (index == chatMessages.length) {
                      return _buildThinkingIndicator();
                    }

                    final message = chatMessages[index];
                    return _buildChatBubble(message);
                  },
                ),
              ),
            ),
          ),

          // Quick Query Suggestion Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: quickQueries.map((query) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text(query, style: const TextStyle(fontSize: 12)),
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      side: BorderSide(color: colorScheme.primary.withOpacity(0.2)),
                      onPressed: () => _sendMessage(query),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Input field row
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Chat input field',
                    hint: 'Type a message here...',
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Share what\'s on your mind...',
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  button: true,
                  label: 'Send Message Button',
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: () => _sendMessage(),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final alignRight = message.isFromUser;

    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: alignRight 
              ? colorScheme.surface 
              : colorScheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: alignRight ? const Radius.circular(16) : Radius.zero,
            bottomRight: alignRight ? Radius.zero : const Radius.circular(16),
          ),
          border: Border.all(
            color: alignRight 
                ? colorScheme.onSurface.withOpacity(0.1) 
                : colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Speaker Label
            Text(
              alignRight ? 'You' : 'MindMate Companion',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: alignRight ? Colors.grey : colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            // Content
            Text(
              message.content,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 14.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            // Timestamp
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                DateFormat('hh:mm a').format(message.timestamp),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.08),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Text(
              'Companion is analyzing...',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
