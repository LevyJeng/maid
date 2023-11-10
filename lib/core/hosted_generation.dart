import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maid/utilities/character.dart';
import 'package:maid/utilities/host.dart';
import 'package:maid/utilities/logger.dart';
import 'package:maid/utilities/message_manager.dart';
import 'package:maid/utilities/model.dart';

class HostedGeneration {
  static List<int> _context = [];
  static List<Map<String, dynamic>> _messages = [];
  
  static void prompt(String input) async {
    _messages = character.getExamples();
    _messages.addAll(MessageManager.getMessages());
    
    final url = Uri.parse("${Host.urlController.text}/api/generate");
    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      "model": "llama2:7b", // TODO: Make this configurable
      "prompt": input,
      "context": _context, // TODO: DEPRECATED SOON
      "system": character.prePromptController.text,
      "messages": _messages,
      "options": {
        "seed": model.parameters["random_seed"] ? -1 : model.parameters["seed"],
        "num_predict": model.parameters["n_predict"],
        "top_k": model.parameters["top_k"],
        "top_p": model.parameters["top_p"],
        "tfs_z": model.parameters["tfs_z"],
        "typical_p": model.parameters["typical_p"],
        "temperature": model.parameters["temperature"],
        "repeat_penalty": model.parameters["penalty_repeat"],
        "presence_penalty": model.parameters["penalty_present"],
        "frequency_penalty": model.parameters["penalty_freq"],
        "mirostat": model.parameters["mirostat"],
        "mirostat_tau": model.parameters["mirostat_tau"],
        "mirostat_eta": model.parameters["mirostat_eta"],
        "penalize_newline": model.parameters["penalize_nl"],
        "num_ctx": model.parameters["n_ctx"],
        "num_batch": model.parameters["n_batch"],
        "num_thread": model.parameters["n_threads"],
      }
    });

    print(_messages);

    try {
      var request = http.Request("POST", url)
        ..headers.addAll(headers)
        ..body = body;

      final streamedResponse = await request.send();

      await for (var value in streamedResponse.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        final data = json.decode(value);
        final responseText = data['response'] as String?;
        final newContext = data['context'] as List<dynamic>?; 
        final done = data['done'] as bool?;

        if (newContext != null) {
          _context = newContext.cast<int>();
        }

        if (responseText != null && responseText.isNotEmpty) {
          MessageManager.stream(responseText);
        }

        if (done ?? false) {
          break;
        }
      }
    } catch (e) {
      Logger.log('Error: $e');
    }

    model.busy = false;
    MessageManager.stream("");
  }
}