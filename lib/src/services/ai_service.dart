import 'dart:math';

class AIService {
  static final Random _random = Random();

  // Katya AI - умный помощник для mesh-сети
  List<String> generateSmartReplies(String context) {
    final lowerContext = context.toLowerCase();

    // Приветствия
    if (lowerContext.contains('привет') ||
        lowerContext.contains('здрав') ||
        lowerContext.contains('hi') ||
        lowerContext.contains('hello')) {
      return [
        'Привет! 👋 Рад(а) видеть тебя в mesh-сети!',
        'Здравствуй! Как дела в космосе? 🚀',
        'Привет! Готов(а) к общению через REChain!',
        'Привет! Katya AI на связи! 👽',
      ];
    }

    // Вопросы
    if (lowerContext.contains('?') ||
        lowerContext.contains('как') ||
        lowerContext.contains('что') ||
        lowerContext.contains('почему')) {
      return [
        'Интересный вопрос! 🤔 Давай разберем вместе',
        'Хороший вопрос! Katya AI анализирует...',
        'Отличный вопрос! Вот что я думаю:',
        'Сложный вопрос! Нужно подумать 🤖',
      ];
    }

    // Благодарности
    if (lowerContext.contains('спасибо') ||
        lowerContext.contains('благодар') ||
        lowerContext.contains('thanks') ||
        lowerContext.contains('thank')) {
      return [
        'Пожалуйста! Всегда рад(а) помочь! 😊',
        'Не за что! Katya AI всегда рядом!',
        'Пожалуйста! Мы команда! 🤝',
        'Рад(а) помочь! Обращайся еще!',
      ];
    }

    // Прощания
    if (lowerContext.contains('пока') ||
        lowerContext.contains('до свидан') ||
        lowerContext.contains('bye') ||
        lowerContext.contains('goodbye')) {
      return [
        'Пока! До встречи в mesh-сети! 👋',
        'До свидания! Katya AI будет скучать!',
        'Пока! Увидимся в космосе! 🚀',
        'До встречи! Береги себя!',
      ];
    }

    // Эмоции
    if (lowerContext.contains('грустн') ||
        lowerContext.contains('печал') ||
        lowerContext.contains('sad') ||
        lowerContext.contains('upset')) {
      return [
        'Не грусти! Katya AI рядом! 🤗',
        'Все будет хорошо! Мы вместе! 💪',
        'Понимаю тебя. Давай поговорим?',
        'Не переживай! Mesh-сеть поддержит!',
      ];
    }

    if (lowerContext.contains('рад') ||
        lowerContext.contains('счастл') ||
        lowerContext.contains('happy') ||
        lowerContext.contains('joy')) {
      return [
        'Отлично! Рад(а) за тебя! 😄',
        'Здорово! Поделись радостью!',
        'Супер! Katya AI тоже рад(а)!',
        'Классно! Давай праздновать! 🎉',
      ];
    }

    // Технические вопросы
    if (lowerContext.contains('mesh') ||
        lowerContext.contains('сеть') ||
        lowerContext.contains('bluetooth') ||
        lowerContext.contains('ble')) {
      return [
        'Mesh-сеть работает отлично! 📡',
        'Bluetooth соединение стабильное!',
        'REChain Mesh на связи!',
        'Технологии работают как часы! ⚙️',
      ];
    }

    // Время
    if (lowerContext.contains('время') ||
        lowerContext.contains('time') ||
        lowerContext.contains('когда') ||
        lowerContext.contains('when')) {
      final now = DateTime.now();
      return [
        'Сейчас ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
        'Время в mesh-сети: ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
        'Katya AI показывает: ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
        'Текущее время: ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      ];
    }

    // Общие ответы
    final generalReplies = [
      'Понял! 👍',
      'Интересно! 🤔',
      'Хорошо! 👌',
      'Согласен(а)! ✅',
      'Отлично! 🎯',
      'Понятно! 📝',
      'Круто! 🔥',
      'Супер! ⭐',
      'Классно! 🚀',
      'Здорово! 💫',
    ];

    return [generalReplies[_random.nextInt(generalReplies.length)]];
  }

  // Анализ настроения сообщения
  String analyzeMood(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('!') &&
        (lowerMessage.contains('отлично') ||
            lowerMessage.contains('супер') ||
            lowerMessage.contains('классно'))) {
      return 'Позитивное настроение! 😊';
    }

    if (lowerMessage.contains('?') && lowerMessage.length > 20) {
      return 'Заинтересованность и любопытство! 🤔';
    }

    if (lowerMessage.contains('спасибо') || lowerMessage.contains('благодар')) {
      return 'Вежливость и благодарность! 🙏';
    }

    if (lowerMessage.length < 10) {
      return 'Краткое сообщение! 📝';
    }

    return 'Нейтральное настроение';
  }

  // Предложения для продолжения разговора
  List<String> generateConversationStarters() {
    return [
      'Как дела в mesh-сети?',
      'Что нового в космосе?',
      'Как работает твое устройство?',
      'Есть ли интересные новости?',
      'Как настроение?',
      'Что планируешь делать?',
      'Есть ли вопросы по REChain?',
      'Как прошел день?',
    ];
  }

  // Помощь с mesh-технологиями
  List<String> getMeshHelp() {
    return [
      'Mesh-сеть позволяет общаться без интернета',
      'Bluetooth обеспечивает прямое соединение устройств',
      'REChain - это безопасная mesh-платформа',
      'Katya AI помогает в общении и анализе',
      'Все сообщения шифруются для безопасности',
    ];
  }
}
