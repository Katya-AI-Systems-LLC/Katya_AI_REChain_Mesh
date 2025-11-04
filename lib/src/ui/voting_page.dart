import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../theme.dart';

class VotingPage extends StatefulWidget {
  const VotingPage({super.key});

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<VotingPoll> _polls = [];
  final List<VotingPoll> _myPolls = [];
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSamplePolls();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSamplePolls() {
    // Загружаем примеры голосований
    _polls.addAll([
      VotingPoll(
        id: uuid.v4(),
        title: 'Лучший мессенджер для mesh-сети',
        description:
            'Какой мессенджер лучше всего подходит для оффлайн общения?',
        options: ['Katya AI REChain', 'Signal', 'Telegram', 'WhatsApp'],
        votes: {
          'Katya AI REChain': 15,
          'Signal': 8,
          'Telegram': 5,
          'WhatsApp': 2,
        },
        creator: 'Device-001',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: true,
      ),
      VotingPoll(
        id: uuid.v4(),
        title: 'Цветовая схема приложения',
        description: 'Какая цветовая схема больше нравится?',
        options: ['Космическая (текущая)', 'Классическая', 'Темная', 'Светлая'],
        votes: {
          'Космическая (текущая)': 12,
          'Классическая': 3,
          'Темная': 7,
          'Светлая': 1,
        },
        creator: 'Device-002',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        isActive: true,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Заголовок и кнопка создания
          Row(
            children: [
              Expanded(
                child: Text(
                  'Голосования',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: KatyaTheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _createNewPoll,
                icon: const Icon(Icons.add),
                label: const Text('Создать'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // TabBar
          Container(
            decoration: BoxDecoration(
              color: KatyaTheme.surface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KatyaTheme.primary.withOpacity(0.3)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: KatyaTheme.accentGradient,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: KatyaTheme.onSurface.withOpacity(0.6),
              tabs: const [
                Tab(icon: Icon(Icons.poll), text: 'Активные'),
                Tab(icon: Icon(Icons.history), text: 'Мои'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildActivePollsTab(), _buildMyPollsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePollsTab() {
    if (_polls.isEmpty) {
      return _buildEmptyState(
        context,
        'Нет активных голосований',
        'Создайте первое голосование или дождитесь появления новых',
        Icons.poll_outlined,
      );
    }

    return ListView.builder(
      itemCount: _polls.length,
      itemBuilder: (context, index) {
        return _buildPollCard(_polls[index]);
      },
    );
  }

  Widget _buildMyPollsTab() {
    if (_myPolls.isEmpty) {
      return _buildEmptyState(
        context,
        'Нет ваших голосований',
        'Создайте первое голосование, чтобы оно появилось здесь',
        Icons.history,
      );
    }

    return ListView.builder(
      itemCount: _myPolls.length,
      itemBuilder: (context, index) {
        return _buildPollCard(_myPolls[index], isOwner: true);
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: KatyaTheme.accentGradient,
              boxShadow: KatyaTheme.spaceShadow,
            ),
            child: Icon(icon, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: KatyaTheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: KatyaTheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _createNewPoll,
            icon: const Icon(Icons.add),
            label: const Text('Создать голосование'),
          ),
        ],
      ),
    );
  }

  Widget _buildPollCard(VotingPoll poll, {bool isOwner = false}) {
    final totalVotes = poll.votes.values.fold(0, (sum, count) => sum + count);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и статус
              Row(
                children: [
                  Expanded(
                    child: Text(
                      poll.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: KatyaTheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: poll.isActive
                          ? KatyaTheme.success.withOpacity(0.2)
                          : KatyaTheme.warning.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: poll.isActive
                            ? KatyaTheme.success
                            : KatyaTheme.warning,
                      ),
                    ),
                    child: Text(
                      poll.isActive ? 'Активно' : 'Завершено',
                      style: TextStyle(
                        color: poll.isActive
                            ? KatyaTheme.success
                            : KatyaTheme.warning,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Описание
              Text(
                poll.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: KatyaTheme.onSurface.withOpacity(0.8),
                    ),
              ),
              const SizedBox(height: 16),

              // Варианты ответов
              ...poll.options.map(
                (option) => _buildOptionRow(
                  option,
                  poll.votes[option] ?? 0,
                  totalVotes,
                  poll.isActive,
                ),
              ),

              const SizedBox(height: 16),

              // Информация о голосовании
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: KatyaTheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$totalVotes голосов',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: KatyaTheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.person,
                    size: 16,
                    color: KatyaTheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    poll.creator,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: KatyaTheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                  const Spacer(),
                  Text(
                    _formatTime(poll.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: KatyaTheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                ],
              ),

              if (isOwner) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editPoll(poll),
                        icon: const Icon(Icons.edit),
                        label: const Text('Редактировать'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _closePoll(poll),
                        icon: const Icon(Icons.close),
                        label: const Text('Закрыть'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KatyaTheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow(
    String option,
    int votes,
    int totalVotes,
    bool isActive,
  ) {
    final percentage = totalVotes > 0 ? (votes / totalVotes) * 100 : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: KatyaTheme.onSurface),
                ),
              ),
              Text(
                '$votes (${percentage.toStringAsFixed(1)}%)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: KatyaTheme.onSurface.withOpacity(0.7),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: KatyaTheme.surface.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage > 50 ? KatyaTheme.success : KatyaTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _createNewPoll() {
    showDialog(
      context: context,
      builder: (context) => CreatePollDialog(
        onPollCreated: (poll) {
          setState(() {
            _myPolls.add(poll);
            _polls.add(poll);
          });
        },
      ),
    );
  }

  void _editPoll(VotingPoll poll) {
    // TODO: Реализовать редактирование голосования
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Редактирование в разработке')),
    );
  }

  void _closePoll(VotingPoll poll) {
    setState(() {
      poll.isActive = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Голосование закрыто')));
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}д назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}м назад';
    } else {
      return 'сейчас';
    }
  }
}

class VotingPoll {
  final String id;
  final String title;
  final String description;
  final List<String> options;
  final Map<String, int> votes;
  final String creator;
  final DateTime createdAt;
  bool isActive;

  VotingPoll({
    required this.id,
    required this.title,
    required this.description,
    required this.options,
    required this.votes,
    required this.creator,
    required this.createdAt,
    this.isActive = true,
  });
}

class CreatePollDialog extends StatefulWidget {
  final Function(VotingPoll) onPollCreated;

  const CreatePollDialog({super.key, required this.onPollCreated});

  @override
  State<CreatePollDialog> createState() => _CreatePollDialogState();
}

class _CreatePollDialogState extends State<CreatePollDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final uuid = const Uuid();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: KatyaTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Создать голосование',
        style: TextStyle(color: KatyaTheme.onSurface),
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Название голосования',
                  hintText: 'Введите название...',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  hintText: 'Опишите детали голосования...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Варианты ответов',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: KatyaTheme.onSurface),
              ),
              const SizedBox(height: 8),
              ...List.generate(_optionControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _optionControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Вариант ${index + 1}',
                            hintText: 'Введите вариант ответа...',
                          ),
                        ),
                      ),
                      if (_optionControllers.length > 2)
                        IconButton(
                          onPressed: () => _removeOption(index),
                          icon: const Icon(
                            Icons.remove_circle,
                            color: KatyaTheme.error,
                          ),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add),
                label: const Text('Добавить вариант'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(onPressed: _createPoll, child: const Text('Создать')),
      ],
    );
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  void _createPoll() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final options = _optionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (title.isEmpty || description.isEmpty || options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заполните все поля и добавьте минимум 2 варианта'),
          backgroundColor: KatyaTheme.error,
        ),
      );
      return;
    }

    final poll = VotingPoll(
      id: uuid.v4(),
      title: title,
      description: description,
      options: options,
      votes: {for (final option in options) option: 0},
      creator: 'Me',
      createdAt: DateTime.now(),
    );

    widget.onPollCreated(poll);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Голосование создано!'),
        backgroundColor: KatyaTheme.success,
      ),
    );
  }
}
