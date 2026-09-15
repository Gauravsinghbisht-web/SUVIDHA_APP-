import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {
  final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-3.6-flash',
  );

  Future<String> askGemini(String question) async {
    try {
      final prompt = '''
You are Suvidha AI Assistant, a helpful assistant for the Suvidha home-service app.

Suvidha helps users find and book workers such as:
- Plumbers
- Electricians
- Carpenters
- Cleaners

Your responsibilities:
1. Understand the user's home-service problem.
2. Suggest the most suitable service.
3. Explain the problem in simple language.
4. Recommend booking a worker through Suvidha when appropriate.
5. Keep your response short and useful.
6. Do not claim that a worker has been booked.
7. If the question is unrelated to home services, politely guide the user back to Suvidha services.

User's question:
$question
''';

      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      return response.text ?? 'No response received from Suvidha AI.';
    } catch (e) {
      return 'Suvidha AI Error: $e';
    }
  }

  Future<Object?> generateResponse(String trim) async {}
}