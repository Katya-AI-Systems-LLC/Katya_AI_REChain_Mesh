import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// App Router configuration using GoRouter
class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Home Page')),
        ),
      ),
      // Add more routes as needed
    ],
  );
}
