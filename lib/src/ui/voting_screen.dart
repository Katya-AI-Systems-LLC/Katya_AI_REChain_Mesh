import 'dart:async';
import 'package:flutter/material.dart';
import '../services/voting_service.dart';
import '../services/ai/offline_ai_helper.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  final VotingService _voting = VotingService.instance;
  final OfflineAIHelper _ai = OfflineAIHelper.instance;
  final List<VotingPoll> _polls = [];
  StreamSubscription<VotingPoll>? _pollSub;
  StreamSubscription<Vote>? _voteSub;
  Map<String, dynamic> _stats = const {};
  String? _aiAnalysis;

  @override
  void initState() {
    super.initState();
    _pollSub = _voting.onPollCreated.listen((p) {
      setState(() {
        final i = _polls.indexWhere((e) => e.id == p.id);
        if (i >= 0) {
          _polls[i] = p;
        } else {
          _polls.insert(0, p);
        }
      });
    });
    _voteSub = _voting.onVoteCasted.listen((_) => setState(() {}));
    () async {
      await _voting.initialize();
      final list = await _voting.getPolls();
      _stats = _voting.getStatistics();
      setState(() {
        _polls
          ..clear()
          ..addAll(list);
      });
    }();
  }

  @override
  void dispose() {
    _pollSub?.cancel();
    _voteSub?.cancel();
    super.dispose();
  }

  Future<void> _createPoll() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final optsCtrl = TextEditingController(text: 'Yes,No');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New poll'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: optsCtrl, decoration: const InputDecoration(labelText: 'Options (comma)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
        ],
      ),
    );
    if (ok != true) return;
    final options = optsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    await _voting.createPoll(
      title: titleCtrl.text,
      description: descCtrl.text,
      options: options,
      creatorId: 'me',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('Voting'),
          const SizedBox(width: 12),
          if (_stats.isNotEmpty)
            Chip(label: Text('polls: ${_stats['total_polls'] ?? 0} • votes: ${_stats['total_votes'] ?? 0}')),
        ]),
        actions: [
          IconButton(onPressed: _createPoll, icon: const Icon(Icons.add)),
        ],
      ),
      body: ListView.builder(
        itemCount: _polls.length,
        itemBuilder: (ctx, i) {
          final p = _polls[i];
          final total = p.votes.values.fold(0, (s, v) => s + v);
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(p.description)),
                      PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'finalize') {
                            try {
                              await _voting.finalizeByMajority(p.id);
                              if (mounted) setState(() {});
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Finalize failed: $e')),
                                );
                              }
                            }
                          } else if (v == 'analyze') {
                            final analysis = await _ai.analyzePoll(p);
                            if (mounted) {
                              setState(() => _aiAnalysis = analysis);
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Row(
                                    children: [
                                      Icon(Icons.psychology, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text('AI Analysis'),
                                    ],
                                  ),
                                  content: SingleChildScrollView(
                                    child: Text(_aiAnalysis ?? ''),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'analyze', child: Text('🤖 AI Analysis')),
                          const PopupMenuItem(value: 'finalize', child: Text('Finalize by majority')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: p.options.map((o) {
                      final count = p.votes[o] ?? 0;
                      final pct = total == 0 ? 0 : (count / total * 100).round();
                      return ActionChip(
                        label: Text('$o ($count/$total • $pct%)'),
                        onPressed: () async {
                          await _voting.vote(pollId: p.id, option: o);
                          setState(() => _stats = _voting.getStatistics());
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
