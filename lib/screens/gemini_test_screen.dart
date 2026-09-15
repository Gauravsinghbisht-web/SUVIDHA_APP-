import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class GeminiTestScreen extends StatefulWidget {
  const GeminiTestScreen({super.key});

  @override
  State<GeminiTestScreen> createState() => _GeminiTestScreenState();
}

class _GeminiTestScreenState extends State<GeminiTestScreen> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _controller = TextEditingController();

  String _response = '';
  bool _isLoading = false;

  Future<void> _askGemini() async {
    if (_controller.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _response = '';
    });

    final String result = await _geminiService.askGemini(
      _controller.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _response = result;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Ask Gemini something...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _askGemini,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Ask Gemini'),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _response,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}