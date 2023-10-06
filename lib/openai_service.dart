import 'dart:convert';

import 'package:ai_spoken_partner/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final List<Map<String, String>> messages = [];
  // Future<String> isArtPromptAPI(String prompt) async {
  //   try {
  //     final res = await http.post(
  //         Uri.parse("https://api.openai.com/v1/chat/completions"),
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer $openAIAPIKey'
  //         },
  //         body: jsonEncode({
  //           "model": "gpt-3.5-turbo",
  //           "messages": [
  //             {
  //               'role': 'user',
  //               'content':
  //                   prompt
  //             }
  //           ],
  //         }));
  //     print(res.body);
  //     if (res.statusCode == 200) {
  //       String content =
  //           json.decode(res.body)['choices'][0]['message']['content'];
  //       content = content.trim().toLowerCase();
  //       if (content == 'yes' || content == 'yes.') {
  //         final response = await dallEAPI(prompt);
  //         return response;
  //       } else {
  //         final response = await chatGPTAPI(prompt);
  //         return response;
  //       }
  //     }
  //     return "An internal error occured.";
  //   } catch (e) {
  //     return e.toString();
  //   }
  // }

  Future<String> chatGPTAPI(String prompt) async {
    print("Chat GPT API called.********** & Prompt is $prompt");
    messages.add({'role': 'user', 'content': prompt});
    try {
      final res = await http.post(
          Uri.parse("https://api.openai.com/v1/chat/completions"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAIAPIKey'
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": messages,
          }));
      if (res.statusCode == 200) {
        String content =
            json.decode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        messages.add({'role': 'assistant', 'content': content});
        print("Chat GPT API response is $content");
        return content;
      }
      print("An internal error occured.");
      return "An internal error occured.";
    } catch (e) {
      print("Error: ${e.toString()}");
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    try {
      final res = await http.post(
          Uri.parse("https://api.openai.com/v1/images/generations"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openAIAPIKey'
          },
          body: jsonEncode({
            'prompt': prompt,
            'n': 1,
          }));
      if (res.statusCode == 200) {
        String imageUrl = json.decode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();
        messages.add({'role': 'assistant', 'content': imageUrl});
        return imageUrl;
      }
      return "An internal error occured.";
    } catch (e) {
      return e.toString();
    }
  }
}
