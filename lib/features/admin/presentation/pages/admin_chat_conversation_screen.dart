import 'package:event_planner/features/admin/domain/entities/admin_chat_user_entity.dart';
import 'package:event_planner/features/admin/presentation/view_model/admin_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminChatConversationScreen extends ConsumerStatefulWidget {
  final AdminChatUserEntity user;

  const AdminChatConversationScreen({super.key, required this.user});

  @override
  ConsumerState<AdminChatConversationScreen> createState() =>
      _AdminChatConversationScreenState();
}

class _AdminChatConversationScreenState
    extends ConsumerState<AdminChatConversationScreen> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminViewModelProvider.notifier).selectChatUser(widget.user);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminViewModelProvider);
    final vm = ref.read(adminViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user.fullName.isEmpty
              ? widget.user.username
              : widget.user.fullName,
        ),
        actions: [
          IconButton(
            onPressed: () => vm.loadUserChat(widget.user.id),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.chatMessages.isEmpty
                ? const Center(child: Text('No messages yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = state.chatMessages[index];
                      final isAdmin = message.from.toLowerCase() == 'admin';
                      return Align(
                        alignment: isAdmin
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 420),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? const Color(0xFF800000)
                                : const Color(0xFFF0F1F4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: isAdmin ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final text = _inputController.text.trim();
                    if (text.isEmpty) return;
                    await vm.sendMessage(
                      userId: widget.user.id,
                      text: text,
                      adminName: 'Admin',
                    );
                    _inputController.clear();
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
