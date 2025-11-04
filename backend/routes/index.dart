import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'status': 'ok',
      'service': 'katya_frog_backend',
      'version': '1.0.0',
      'time': DateTime.now().toIso8601String(),
      'endpoints': {
        'messages': '/messages',
        'polls': '/polls',
        'devices': '/devices',
        'sync': '/sync',
        'stats': '/stats',
      },
      'description':
          'Katya AI REChain Mesh Backend - Offline Mesh Messenger & Voting API',
      'features': [
        'Message synchronization',
        'Poll management',
        'Device discovery',
        'Real-time voting',
        'Mesh network support',
      ],
    },
  );
}
