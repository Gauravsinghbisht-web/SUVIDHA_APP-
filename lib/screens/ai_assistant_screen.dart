
import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() =>
      _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _controller =
      TextEditingController();

  final List<Map<String, String>> _messages = [];

  bool _isLoading = false;

  Future<void> _askGemini() async {
    final String question = _controller.text.trim();

    if (question.isEmpty || _isLoading) {
      return;
    }

    setState(() {
      _messages.add({
        'sender': 'user',
        'message': question,
      });

      _controller.clear();
      _isLoading = true;
    });

    final String result =
        await _geminiService.askGemini(question);

    if (!mounted) return;

    setState(() {
      _messages.add({
        'sender': 'ai',
        'message': result,
      });

      _isLoading = false;
    });
  }

  void _useSuggestion(String text) {
    _controller.text = text;

    _askGemini();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                color: primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Suvidha AI'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcomeSection()
                : _buildMessages(),
          ),

          if (_isLoading)
            _buildLoadingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 25),

          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 42,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'How can I help you?',
            style: Theme.of(context)
                .textTheme
                .headlineMedium,
          ),

          const SizedBox(height: 8),

          Text(
            'Describe your home-service problem and I will help you find the right service.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),

          const SizedBox(height: 28),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Try asking',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),
          ),

          const SizedBox(height: 12),

          _suggestionCard(
            icon: Icons.water_drop_outlined,
            text: 'My kitchen tap is leaking',
          ),

          const SizedBox(height: 10),

          _suggestionCard(
            icon: Icons.electrical_services,
            text: 'There is a problem with my fan',
          ),

          const SizedBox(height: 10),

          _suggestionCard(
            icon: Icons.cleaning_services,
            text: 'I need help cleaning my house',
          ),

          const SizedBox(height: 10),

          _suggestionCard(
            icon: Icons.handyman_outlined,
            text: 'I need a carpenter for my furniture',
          ),
        ],
      ),
    );
  }

  Widget _suggestionCard({
    required IconData icon,
    required String text,
  }) {
    final primary =
        Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          _useSuggestion(text);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        20,
      ),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];

        final bool isUser =
            message['sender'] == 'user';

        return _messageBubble(
          message['message'] ?? '',
          isUser,
        );
      },
    );
  }

  Widget _messageBubble(
    String message,
    bool isUser,
  ) {
    final primary =
        Theme.of(context).colorScheme.primary;

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width * 0.80,
        ),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? primary
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(
              isUser ? 18 : 4,
            ),
            bottomRight: Radius.circular(
              isUser ? 4 : 18,
            ),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: Colors.grey.shade200,
                ),
        ),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 15,
            height: 1.4,
            color: isUser
                ? Colors.white
                : const Color(0xFF344054),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        10,
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 18,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Suvidha AI is thinking...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final primary =
        Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                _askGemini();
              },
              decoration: InputDecoration(
                hintText:
                    'Describe your problem...',
                prefixIcon: const Icon(
                  Icons.chat_bubble_outline,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed:
                  _isLoading ? null : _askGemini,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
