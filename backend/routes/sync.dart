import 'package:dart_frog/dart_frog.dart';

// In-memory store for demo (в реальном приложении использовать базу данных)
final List<Map<String, dynamic>> _messages = [];
final List<Map<String, dynamic>> _polls = [];
final List<Map<String, dynamic>> _devices = [];

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;
  final uri = context.request.uri;

  try {
    switch (method) {
      case HttpMethod.get:
        return _handleGet(uri);
      case HttpMethod.post:
        return await _handlePost(context);
      case HttpMethod.put:
        return await _handlePut(context);
      case HttpMethod.delete:
        return _handleDelete(uri);
      default:
        return Response.json(
          statusCode: 405,
          body: {'error': 'Method not allowed'},
        );
    }
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error: $e'},
    );
  }
}

Response _handleGet(Uri uri) {
  final path = uri.path;

  switch (path) {
    case '/messages':
      return Response.json(
        body: {
          'status': 'ok',
          'messages': _messages,
          'count': _messages.length,
        },
      );

    case '/polls':
      return Response.json(
        body: {'status': 'ok', 'polls': _polls, 'count': _polls.length},
      );

    case '/devices':
      return Response.json(
        body: {'status': 'ok', 'devices': _devices, 'count': _devices.length},
      );

    case '/stats':
      return Response.json(
        body: {
          'status': 'ok',
          'stats': {
            'messages': _messages.length,
            'polls': _polls.length,
            'devices': _devices.length,
            'uptime': DateTime.now().millisecondsSinceEpoch,
          },
        },
      );

    default:
      return Response.json(statusCode: 404, body: {'error': 'Not found'});
  }
}

Future<Response> _handlePost(RequestContext context) async {
  final uri = context.request.uri;
  final path = uri.path;
  final payload = await context.request.json() as Map<String, dynamic>;

  switch (path) {
    case '/messages':
      return _addMessage(payload);

    case '/polls':
      return _addPoll(payload);

    case '/devices':
      return _addDevice(payload);

    case '/sync':
      return _syncData(payload);

    default:
      return Response.json(statusCode: 404, body: {'error': 'Not found'});
  }
}

Future<Response> _handlePut(RequestContext context) async {
  final uri = context.request.uri;
  final path = uri.path;
  final payload = await context.request.json() as Map<String, dynamic>;

  switch (path) {
    case '/polls/vote':
      return _votePoll(payload);

    case '/messages/status':
      return _updateMessageStatus(payload);

    default:
      return Response.json(statusCode: 404, body: {'error': 'Not found'});
  }
}

Response _handleDelete(Uri uri) {
  final path = uri.path;

  if (path.startsWith('/messages/')) {
    final id = path.split('/').last;
    _messages.removeWhere((msg) => msg['id'] == id);
    return Response.json(body: {'status': 'ok', 'deleted': id});
  }

  if (path.startsWith('/polls/')) {
    final id = path.split('/').last;
    _polls.removeWhere((poll) => poll['id'] == id);
    return Response.json(body: {'status': 'ok', 'deleted': id});
  }

  return Response.json(statusCode: 404, body: {'error': 'Not found'});
}

Response _addMessage(Map<String, dynamic> payload) {
  final message = {
    'id': payload['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    'fromId': payload['fromId'],
    'toId': payload['toId'],
    'body': payload['body'],
    'timestamp': payload['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    'status': payload['status'] ?? 'sent',
    'encrypted': payload['encrypted'] ?? false,
  };

  _messages.add(message);

  return Response.json(
    body: {
      'status': 'ok',
      'message': message,
      'totalMessages': _messages.length,
    },
  );
}

Response _addPoll(Map<String, dynamic> payload) {
  final poll = {
    'id': payload['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    'title': payload['title'],
    'description': payload['description'],
    'options': payload['options'],
    'votes': payload['votes'] ?? {},
    'creator': payload['creator'],
    'createdAt': payload['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
    'isActive': payload['isActive'] ?? true,
  };

  _polls.add(poll);

  return Response.json(
    body: {'status': 'ok', 'poll': poll, 'totalPolls': _polls.length},
  );
}

Response _addDevice(Map<String, dynamic> payload) {
  final device = {
    'id': payload['id'],
    'name': payload['name'],
    'type': payload['type'] ?? 'mobile',
    'lastSeen': DateTime.now().millisecondsSinceEpoch,
    'isOnline': true,
  };

  // Обновляем существующее устройство или добавляем новое
  final existingIndex = _devices.indexWhere((d) => d['id'] == device['id']);
  if (existingIndex >= 0) {
    _devices[existingIndex] = device;
  } else {
    _devices.add(device);
  }

  return Response.json(
    body: {'status': 'ok', 'device': device, 'totalDevices': _devices.length},
  );
}

Response _votePoll(Map<String, dynamic> payload) {
  final pollId = payload['pollId'];
  final option = payload['option'];
  final voterId = payload['voterId'];

  final pollIndex = _polls.indexWhere((p) => p['id'] == pollId);
  if (pollIndex == -1) {
    return Response.json(statusCode: 404, body: {'error': 'Poll not found'});
  }

  final poll = _polls[pollIndex];
  if (!poll['isActive']) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Poll is not active'},
    );
  }

  // Обновляем голоса
  final votes = Map<String, int>.from(poll['votes']);
  votes[option] = (votes[option] ?? 0) + 1;
  poll['votes'] = votes;

  _polls[pollIndex] = poll;

  return Response.json(
    body: {'status': 'ok', 'poll': poll, 'votedOption': option},
  );
}

Response _updateMessageStatus(Map<String, dynamic> payload) {
  final messageId = payload['messageId'];
  final status = payload['status'];

  final messageIndex = _messages.indexWhere((m) => m['id'] == messageId);
  if (messageIndex == -1) {
    return Response.json(statusCode: 404, body: {'error': 'Message not found'});
  }

  _messages[messageIndex]['status'] = status;

  return Response.json(
    body: {'status': 'ok', 'message': _messages[messageIndex]},
  );
}

Response _syncData(Map<String, dynamic> payload) {
  final clientMessages = List<Map<String, dynamic>>.from(
    payload['messages'] ?? [],
  );
  final clientPolls = List<Map<String, dynamic>>.from(payload['polls'] ?? []);

  // Простая синхронизация - добавляем новые данные
  for (final msg in clientMessages) {
    if (!_messages.any((m) => m['id'] == msg['id'])) {
      _messages.add(msg);
    }
  }

  for (final poll in clientPolls) {
    if (!_polls.any((p) => p['id'] == poll['id'])) {
      _polls.add(poll);
    }
  }

  return Response.json(
    body: {
      'status': 'ok',
      'synced': {
        'messages': _messages.length,
        'polls': _polls.length,
        'devices': _devices.length,
      },
      'serverData': {
        'messages': _messages,
        'polls': _polls,
        'devices': _devices,
      },
    },
  );
}
