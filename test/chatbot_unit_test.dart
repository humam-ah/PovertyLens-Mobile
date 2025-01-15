import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should add welcome message to the list', () {
    final messages = <Map<String, String>>[];
    final updatedMessages = addWelcomeMessage(messages);

    print('Updated messages: $updatedMessages');

    final matcher = const DeepCollectionEquality().equals;

    final expectedMessage = {
      'sender': 'bot',
      'text': 'Selamat datang di PovertyLens! Ada yang bisa kami bantu?',
    };

    final containsMessage = updatedMessages.any((message) => matcher(message, expectedMessage));
    expect(containsMessage, true, reason: 'Messages should contain the welcome message');
  });
}

addWelcomeMessage(List<Map<String, String>> messages) {
  messages.add({
    'sender': 'bot',
    'text': 'Selamat datang di PovertyLens! Ada yang bisa kami bantu?',
  });
  return messages;
}
