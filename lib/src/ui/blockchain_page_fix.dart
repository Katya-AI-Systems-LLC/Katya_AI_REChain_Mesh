// This is a temporary helper file with the complete _showContractDetails method
// Copy this method into blockchain_page.dart starting at line 1486

  void _showContractDetails(SmartContract contract) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: KatyaTheme.surface,
        title: Text(
          contract.name,
          style: KatyaTheme.heading3.copyWith(
            color: KatyaTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contract.description,
              style: KatyaTheme.body.copyWith(
                color: KatyaTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '• Адрес: ${contract.address}',
              style: KatyaTheme.body.copyWith(
                color: KatyaTheme.textPrimary,
              ),
            ),
            Text(
              '• Деплойер: ${contract.deployerWalletId}',
              style: KatyaTheme.body.copyWith(
                color: KatyaTheme.textPrimary,
              ),
            ),
            Text(
              '• Статус: ${contract.isActive ? 'Активен' : 'Неактивен'}',
              style: KatyaTheme.body.copyWith(
                color: KatyaTheme.textPrimary,
              ),
            ),
            Text(
              '• Создан: ${contract.createdAt.toLocal()}',
              style: KatyaTheme.body.copyWith(
                color: KatyaTheme.textPrimary,
              ),
            ),
            if (contract.parameters.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Параметры:',
                style: KatyaTheme.body.copyWith(
                  color: KatyaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              ...contract.parameters.entries.map(
                (entry) => Text(
                  '• ${entry.key}: ${entry.value}',
                  style: KatyaTheme.caption.copyWith(
                    color: KatyaTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Закрыть',
              style: KatyaTheme.button.copyWith(
                color: KatyaTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
