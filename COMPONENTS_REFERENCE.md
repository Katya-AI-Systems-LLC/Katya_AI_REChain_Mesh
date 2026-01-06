# 📚 Справочник компонентов Enhanced UI System

## 🎯 Быстрый доступ

Этот документ содержит примеры использования всех компонентов Enhanced UI System.

---

## 1️⃣ ModernAppBar

Современный AppBar с поддержкой кастомизации.

### Использование:
```dart
ModernAppBar(
  title: 'Мой экран',
  showBackButton: true,
  onBackPressed: () => Navigator.pop(context),
  actions: [
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {},
    ),
  ],
)
```

### Параметры:
- `title: String` - Заголовок
- `actions: List<Widget>?` - Действия справа
- `showBackButton: bool` - Показать кнопку назад
- `onBackPressed: VoidCallback?` - Callback при нажатии назад
- `backgroundColor: Color?` - Цвет фона
- `showDivider: bool` - Показать разделитель

---

## 2️⃣ ModernCard

Интерактивная карточка с эффектами при наведении.

### Использование:
```dart
ModernCard(
  onTap: () => print('Нажата карточка'),
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.all(8),
  borderRadius: 16,
  child: Column(
    children: [
      Text('Заголовок', style: EnhancedTheme.headingS),
      SizedBox(height: 8),
      Text('Содержимое', style: EnhancedTheme.bodyM),
    ],
  ),
)
```

### Параметры:
- `child: Widget` - Содержимое карточки
- `onTap: VoidCallback?` - Callback при нажатии
- `padding: EdgeInsets` - Внутренние отступы
- `margin: EdgeInsets` - Внешние отступы
- `backgroundColor: Color?` - Цвет фона
- `borderRadius: double` - Радиус скругления
- `enableHover: bool` - Включить эффект при наведении
- `animationDuration: Duration` - Длительность анимации
- `shadows: List<BoxShadow>?` - Кастомные тени

---

## 3️⃣ ShimmerLoading

Анимированный loading индикатор с shimmer эффектом.

### Использование (skeletonный экран):
```dart
// Для заголовка
ShimmerLoading(
  height: 24,
  width: 200,
  borderRadius: BorderRadius.all(Radius.circular(6)),
)

// Для текста
ShimmerLoading(
  height: 16,
  width: double.infinity,
)

// Полный пример
Column(
  children: [
    ShimmerLoading(height: 100, width: double.infinity), // Изображение
    SizedBox(height: 12),
    ShimmerLoading(height: 20, width: 250),  // Заголовок
    SizedBox(height: 8),
    ShimmerLoading(height: 14, width: 300),  // Описание
    SizedBox(height: 8),
    ShimmerLoading(height: 14, width: 280),  // Описание
  ],
)
```

### Параметры:
- `height: double` - Высота
- `width: double` - Ширина (по умолчанию infinity)
- `borderRadius: BorderRadius` - Скругление углов

---

## 4️⃣ AnimatedIconButton

Кнопка с иконкой и анимацией масштабирования.

### Использование:
```dart
AnimatedIconButton(
  icon: Icons.send_rounded,
  onPressed: () => print('Отправлено'),
  color: EnhancedTheme.accent,
  size: 24,
  showLabel: true,
  label: 'Отправить',
)
```

### Параметры:
- `icon: IconData` - Иконка
- `onPressed: VoidCallback?` - Callback при нажатии
- `color: Color?` - Цвет иконки
- `size: double` - Размер иконки
- `animationDuration: Duration` - Длительность анимации
- `showLabel: bool` - Показать ярлык
- `label: String?` - Текст ярлыка

---

## 5️⃣ ModernChip

Чип с поддержкой selected состояния.

### Использование:
```dart
// Одиночный чип
ModernChip(
  label: 'Фильтр',
  selected: isSelected,
  onSelected: (selected) {
    setState(() => isSelected = selected);
  },
  icon: Icons.filter_list,
)

// Список чипов
Row(
  children: [
    ModernChip(
      label: 'Все',
      selected: selectedFilter == 'all',
      onSelected: (selected) {
        setState(() => selectedFilter = selected ? 'all' : null);
      },
    ),
    SizedBox(width: 8),
    ModernChip(
      label: 'Новые',
      selected: selectedFilter == 'new',
      onSelected: (selected) {
        setState(() => selectedFilter = selected ? 'new' : null);
      },
    ),
    SizedBox(width: 8),
    ModernChip(
      label: 'Архив',
      selected: selectedFilter == 'archive',
      onSelected: (selected) {
        setState(() => selectedFilter = selected ? 'archive' : null);
      },
    ),
  ],
)
```

### Параметры:
- `label: String` - Текст чипа
- `selected: bool` - Выбран ли чип
- `onSelected: VoidCallback?` - Callback при выборе
- `icon: IconData?` - Иконка чипа
- `backgroundColor: Color?` - Цвет фона
- `labelColor: Color?` - Цвет текста
- `padding: EdgeInsets` - Отступы

---

## 6️⃣ StatusIndicator

Индикатор статуса с пульсирующей анимацией.

### Использование:
```dart
// Простой индикатор
StatusIndicator(
  isActive: isConnected,
  activeColor: Colors.green,
  inactiveColor: Colors.grey,
)

// С ярлыком
StatusIndicator(
  isActive: isConnected,
  activeColor: EnhancedTheme.success,
  label: isConnected ? 'Подключено' : 'Отключено',
)

// В Row
Row(
  children: [
    StatusIndicator(
      isActive: device.isConnected,
      activeColor: EnhancedTheme.success,
      size: 12,
    ),
    SizedBox(width: 8),
    Text(device.name),
  ],
)
```

### Параметры:
- `isActive: bool` - Активен ли индикатор
- `activeColor: Color?` - Цвет активного состояния
- `inactiveColor: Color?` - Цвет неактивного состояния
- `size: double` - Размер индикатора
- `label: String?` - Опциональный ярлык

---

## 7️⃣ EmptyState

Красивое отображение пустого состояния.

### Использование:
```dart
// Базовый пример
EmptyState(
  icon: Icons.inbox_outlined,
  title: 'Нет сообщений',
  subtitle: 'Пока что сообщений нет',
)

// С действием
EmptyState(
  icon: Icons.add_rounded,
  title: 'Нет элементов',
  subtitle: 'Создайте первый элемент',
  action: ElevatedButton.icon(
    onPressed: () => _createItem(),
    icon: Icon(Icons.add),
    label: Text('Создать'),
  ),
)

// В ListView
ListView(
  children: items.isEmpty
      ? [
          EmptyState(
            icon: Icons.list_outlined,
            title: 'Нет элементов',
            subtitle: 'Список пуст',
          ),
        ]
      : items.map((item) => ListTile(title: Text(item.title))).toList(),
)
```

### Параметры:
- `icon: IconData` - Иконка
- `title: String` - Основной текст
- `subtitle: String` - Вспомогательный текст
- `action: Widget?` - Опциональная кнопка действия

---

## 8️⃣ ModernDivider

Разделитель с опциональным текстом.

### Использование:
```dart
// Простой разделитель
ModernDivider()

// Разделитель с текстом
ModernDivider(
  text: 'или',
  color: EnhancedTheme.border,
)

// С кастомными отступами
ModernDivider(
  text: 'Следующий раздел',
  padding: EdgeInsets.symmetric(vertical: 20),
)
```

### Параметры:
- `text: String?` - Опциональный текст
- `color: Color?` - Цвет разделителя
- `height: double` - Высота элемента
- `padding: EdgeInsets` - Отступы вокруг

---

## 9️⃣ Типографические стили

Используйте готовые стили для текста.

### Заголовки:
```dart
Text('Очень большой заголовок', style: EnhancedTheme.headingXL)  // 32px
Text('Большой заголовок', style: EnhancedTheme.headingL)         // 28px
Text('Средний заголовок', style: EnhancedTheme.headingM)         // 24px
Text('Маленький заголовок', style: EnhancedTheme.headingS)       // 20px
```

### Подзаголовки:
```dart
Text('Подзаголовок L', style: EnhancedTheme.titleL)  // 18px, w600
Text('Подзаголовок M', style: EnhancedTheme.titleM)  // 16px, w500
Text('Подзаголовок S', style: EnhancedTheme.titleS)  // 14px, w500
```

### Основной текст:
```dart
Text('Основной текст L', style: EnhancedTheme.bodyL)  // 16px
Text('Основной текст M', style: EnhancedTheme.bodyM)  // 14px
Text('Основной текст S', style: EnhancedTheme.bodyS)  // 12px
```

### Ярлыки:
```dart
Text('Ярлык L', style: EnhancedTheme.labelL)  // 14px, w500
Text('Ярлык M', style: EnhancedTheme.labelM)  // 12px, w500
Text('Ярлык S', style: EnhancedTheme.labelS)  // 11px, w500
```

---

## 🔟 Цветовые токены

### Основные цвета:
```dart
color: EnhancedTheme.primary           // #6C63FF - фиолетовый
color: EnhancedTheme.accent            // #00D1FF - голубой
color: EnhancedTheme.secondary         // #9C27B0 - пурпурный
color: EnhancedTheme.tertiary          // #FF6B6B - коралловый
```

### Состояния:
```dart
color: EnhancedTheme.success           // #4CAF50 - успех
color: EnhancedTheme.warning           // #FF9800 - предупреждение
color: EnhancedTheme.error             // #F44336 - ошибка
color: EnhancedTheme.info              // #00BCD4 - информация
```

### Фон и текст:
```dart
color: EnhancedTheme.darkBg            // Основной фон
color: EnhancedTheme.darkSurface       // Поверхность элементов
color: EnhancedTheme.textPrimary       // Основной текст
color: EnhancedTheme.textSecondary     // Вторичный текст
color: EnhancedTheme.border            // Границы и разделители
```

---

## 1️⃣1️⃣ Градиенты

### Готовые градиенты:
```dart
// Фоновый градиент
decoration: BoxDecoration(
  gradient: EnhancedTheme.spaceGradient,
)

// Градиент для кнопок
decoration: BoxDecoration(
  gradient: EnhancedTheme.accentGradient,
)

// Градиент успеха
decoration: BoxDecoration(
  gradient: EnhancedTheme.successGradient,
)

// Градиент ошибки
decoration: BoxDecoration(
  gradient: EnhancedTheme.errorGradient,
)
```

---

## 1️⃣2️⃣ Тени

### Готовые тени:
```dart
// Основные тени для карточек
boxShadow: EnhancedTheme.primaryShadow

// Легкие тени
boxShadow: EnhancedTheme.lightShadow

// Приподнятые тени
boxShadow: EnhancedTheme.elevatedShadow
```

---

## 📝 Полный пример экрана

```dart
import 'package:flutter/material.dart';
import 'package:katya_ai_rechain_mesh/src/enhanced_theme.dart';
import 'package:katya_ai_rechain_mesh/src/ui/components/enhanced_ui_components.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  List<String> items = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: 'Мой экран',
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? Column(
              children: [
                ShimmerLoading(height: 20, width: 200),
                SizedBox(height: 12),
                ShimmerLoading(height: 16),
              ],
            )
          : items.isEmpty
              ? EmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'Нет элементов',
                  subtitle: 'Создайте первый элемент',
                  action: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.add),
                    label: Text('Создать'),
                  ),
                )
              : ListView(
                  children: items
                      .map((item) => ModernCard(
                            onTap: () {},
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item,
                                    style: EnhancedTheme.bodyL,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: EnhancedTheme.accent,
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

## 🎓 Лучшие практики

### ✅ Делайте так:
```dart
// Используйте компоненты из системы
ModernCard(
  child: Text('Content', style: EnhancedTheme.bodyM),
)

// Используйте токены цветов
color: EnhancedTheme.primary

// Используйте готовые стили
Text('Text', style: EnhancedTheme.headingS)
```

### ❌ Не делайте так:
```dart
// Не создавайте Container вместо ModernCard
Container(
  decoration: BoxDecoration(color: Colors.blue),
  child: Text('Content'),
)

// Не используйте хардкод цветов
color: Color(0xFF6C63FF)

// Не создавайте TextStyle с нуля
Text('Text', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
```

---

**Версия:** 1.0.0  
**Последнее обновление:** 2025-01-06  
**Статус:** Complete ✅
