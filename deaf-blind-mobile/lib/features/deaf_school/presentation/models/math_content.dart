import 'package:flutter/material.dart';

/// Accent colors for the math module.
abstract final class MathColors {
  static const primary = Color(0xFFFF8A4C);
  static const primaryLight = Color(0xFFFFAB76);
  static const soft = Color(0xFFFFF1E6);
  static const map = Color(0xFFFFF5EE);
  static const teal = Color(0xFF19BBD6);
  static const tealSoft = Color(0xFFE0F7FB);
}

enum MathTaskType {
  pickDigit,
  tapAll,
  pickLargerGroup,
  dragSign,
  pickShape,
  pickPattern,
  buildEquation,
  fillBlank,
  yesNo,
  dragOrder,
  pickMatchingCount,
}

/// One screen of the visual lesson before the test.
class MathLessonStep {
  const MathLessonStep({
    required this.headline,
    required this.caption,
    this.itemEmoji,
    this.itemCount = 0,
    this.showBasket = false,
  });

  final String headline;
  final String caption;
  final String? itemEmoji;
  final int itemCount;
  final bool showBasket;
}

String mathRepeatItems(String emoji, int count) =>
    count <= 0 ? '' : List.generate(count, (_) => emoji).join();

List<int> _digitOptions(int d) {
  final set = <int>{d, d - 1, d + 1, d + 2, d - 2};
  final opts = set.where((n) => n >= 0 && n <= 10).toList()..sort();
  while (opts.length < 4) {
    for (var i = 0; i <= 10 && opts.length < 4; i++) {
      if (!opts.contains(i)) opts.add(i);
    }
  }
  opts.sort();
  return opts.length > 4 ? opts.sublist(0, 4) : opts;
}

enum MathShape { circle, square, triangle, rectangle }

class MathTask {
  const MathTask({
    required this.type,
    required this.prompt,
    this.emoji,
    this.digit,
    this.count,
    this.left,
    this.right,
    this.options,
    this.correctIndex,
    this.correctSign,
    this.shape,
    this.pattern,
    this.equationParts,
    this.orderItems,
    this.itemEmoji,
    this.useBasket = false,
  });

  final MathTaskType type;
  final String prompt;
  final String? emoji;
  final int? digit;
  final int? count;
  final int? left;
  final int? right;
  final List<int>? options;
  final int? correctIndex;
  final String? correctSign;
  final MathShape? shape;
  final List<String>? pattern;
  final List<int>? equationParts;
  final List<String>? orderItems;
  final String? itemEmoji;
  final bool useBasket;

  bool check(dynamic answer) {
    return switch (type) {
      MathTaskType.pickDigit ||
      MathTaskType.fillBlank ||
      MathTaskType.pickMatchingCount =>
        answer == digit,
      MathTaskType.tapAll => answer == count,
      MathTaskType.pickLargerGroup => answer == correctIndex,
      MathTaskType.dragSign => answer == correctSign,
      MathTaskType.pickShape => answer == shape,
      MathTaskType.pickPattern => answer == pattern?.last,
      MathTaskType.buildEquation => _checkEquation(answer as List<int?>?),
      MathTaskType.yesNo => answer == (correctIndex == 1),
      MathTaskType.dragOrder => _checkOrder(answer as List<String>?),
    };
  }

  bool _checkEquation(List<int?>? slots) {
    if (equationParts == null || slots == null) return false;
    final a = equationParts![0];
    final b = equationParts![1];
    final c = equationParts![2];
    if (a - b == c) {
      return slots.length >= 2 && slots[1] == b;
    }
    if (slots.length != 3) return false;
    return slots[0] == a && slots[1] == b && slots[2] == c;
  }

  bool _checkOrder(List<String>? order) {
    if (orderItems == null || order == null) return false;
    if (order.length != orderItems!.length) return false;
    for (var i = 0; i < orderItems!.length; i++) {
      if (order[i] != orderItems![i]) return false;
    }
    return true;
  }
}

class MathNode {
  const MathNode({
    required this.id,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.heroLabel,
    required this.emoji,
    required this.tipHint,
    required this.visualCaption,
    required this.lessonSteps,
    required this.tasks,
  });

  final String id;
  final int level;
  final String title;
  final String subtitle;
  final String heroLabel;
  final String emoji;
  final String tipHint;
  final String visualCaption;
  final List<MathLessonStep> lessonSteps;
  final List<MathTask> tasks;
}

class MathLevelInfo {
  const MathLevelInfo({
    required this.level,
    required this.title,
    required this.subtitle,
  });

  final int level;
  final String title;
  final String subtitle;
}

const mathLevels = [
  MathLevelInfo(level: 1, title: 'Числа', subtitle: '0–10 · счёт'),
  MathLevelInfo(level: 2, title: 'Больше · Меньше', subtitle: '> < = · сравнение'),
  MathLevelInfo(level: 3, title: 'Сложение', subtitle: 'Примеры до 10'),
  MathLevelInfo(level: 4, title: 'Вычитание · Фигуры', subtitle: '− · формы · ряды'),
  MathLevelInfo(level: 5, title: 'В жизни', subtitle: 'Деньги · время · задачи'),
];

List<MathNode> buildMathCatalog() => [
      ..._level1(),
      ..._level2(),
      ..._level3(),
      ..._level4(),
      ..._level5(),
    ];

MathNode? mathNodeById(String? id) {
  if (id == null) return null;
  for (final n in buildMathCatalog()) {
    if (n.id == id) return n;
  }
  return null;
}

String? nextMathNodeId(String currentId) {
  final catalog = buildMathCatalog();
  for (var i = 0; i < catalog.length - 1; i++) {
    if (catalog[i].id == currentId) return catalog[i + 1].id;
  }
  return null;
}

List<MathNode> _level1() => [
      _appleDigitNode('L1_N0', 0, 'Цифра 0', 'Ничего нет'),
      _appleDigitNode('L1_N1', 1, 'Цифра 1', 'Одно яблоко'),
      _appleDigitNode('L1_N2', 2, 'Цифра 2', 'Два яблока'),
      _appleDigitNode('L1_N3', 3, 'Цифра 3', 'Три яблока'),
      _itemDigitNode(
        id: 'L1_N4',
        digits: [4, 5],
        item: '🍊',
        itemName: 'апельсин',
        title: 'Цифры 4–5',
        subtitle: 'Апельсины',
      ),
      _itemDigitNode(
        id: 'L1_N5',
        digits: [6, 7],
        item: '🍬',
        itemName: 'конфета',
        title: 'Цифры 6–7',
        subtitle: 'Конфеты',
      ),
      _itemDigitNode(
        id: 'L1_N6',
        digits: [8, 9, 10],
        item: '⭐',
        itemName: 'звезда',
        title: 'Цифры 8–10',
        subtitle: 'Звёзды',
      ),
      const MathNode(
        id: 'L1_N7',
        level: 1,
        title: 'Считаем',
        subtitle: 'Нажми на каждый',
        heroLabel: '4',
        emoji: '🍎',
        tipHint: 'Нажимай по одному и считай',
        visualCaption: 'Посчитай все яблоки',
        lessonSteps: [
          MathLessonStep(
            headline: '4',
            caption: 'Нажми на каждое яблоко по очереди',
            itemEmoji: '🍎',
            itemCount: 4,
            showBasket: true,
          ),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.tapAll,
            prompt: 'Нажми на каждое яблоко',
            itemEmoji: '🍎',
            useBasket: true,
            count: 4,
          ),
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: 'Сколько яблок ты насчитал?',
            itemEmoji: '🍎',
            useBasket: true,
            count: 4,
            digit: 4,
            options: [2, 3, 4, 5],
          ),
        ],
      ),
      const MathNode(
        id: 'L1_N8',
        level: 1,
        title: 'Повторение',
        subtitle: 'Закрепление',
        heroLabel: '✓',
        emoji: '🔢',
        tipHint: 'Посчитай предметы на картинке',
        visualCaption: 'Выбери правильную цифру',
        lessonSteps: [
          MathLessonStep(
            headline: '?',
            caption: 'Посмотри на предметы и выбери цифру',
            itemEmoji: '📚',
            itemCount: 5,
          ),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: 'Сколько книг?',
            itemEmoji: '📚',
            count: 5,
            digit: 5,
            options: [3, 4, 5, 6],
          ),
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: 'Сколько пальцев на одной руке?',
            digit: 5,
            options: [4, 5, 6, 7],
          ),
        ],
      ),
    ];

MathNode _appleDigitNode(String id, int digit, String title, String subtitle) {
  final appleWord = switch (digit) {
    0 => 'яблок',
    1 => 'яблоко',
    2 => 'яблока',
    3 => 'яблока',
    _ => 'яблок',
  };
  final caption = digit == 0
      ? 'Корзина пустая — это 0'
      : '$digit $appleWord в корзине — цифра $digit';

  return MathNode(
    id: id,
    level: 1,
    title: title,
    subtitle: subtitle,
    heroLabel: '$digit',
    emoji: digit == 0 ? '🧺' : '🍎',
    tipHint: digit == 0 ? 'Ноль — когда ничего нет' : 'Посчитай яблоки в корзине',
    visualCaption: caption,
    lessonSteps: [
      MathLessonStep(
        headline: '$digit',
        caption: caption,
        itemEmoji: '🍎',
        itemCount: digit,
        showBasket: true,
      ),
    ],
    tasks: [
      MathTask(
        type: MathTaskType.pickDigit,
        prompt: digit == 0 ? 'Сколько яблок в корзине?' : 'Сколько яблок?',
        itemEmoji: '🍎',
        useBasket: true,
        count: digit,
        digit: digit,
        options: _digitOptions(digit),
      ),
      MathTask(
        type: MathTaskType.pickDigit,
        prompt: 'Какая это цифра?',
        itemEmoji: '🍎',
        useBasket: true,
        count: digit,
        digit: digit,
        options: _digitOptions(digit),
      ),
    ],
  );
}

MathNode _itemDigitNode({
  required String id,
  required List<int> digits,
  required String item,
  required String itemName,
  required String title,
  required String subtitle,
}) {
  final steps = digits.map((d) {
    final word = switch (d) {
      1 => itemName,
      2 || 3 || 4 => '$itemNameа',
      _ => itemName,
    };
    return MathLessonStep(
      headline: '$d',
      caption: '$d $word — цифра $d',
      itemEmoji: item,
      itemCount: d,
    );
  }).toList();

  final tasks = digits.map((d) {
    return MathTask(
      type: MathTaskType.pickDigit,
      prompt: 'Сколько ${_pluralItem(itemName, d)}?',
      itemEmoji: item,
      count: d,
      digit: d,
      options: _digitOptions(d),
    );
  }).toList();

  return MathNode(
    id: id,
    level: 1,
    title: title,
    subtitle: subtitle,
    heroLabel: '${digits.first}',
    emoji: item,
    tipHint: 'Посчитай предметы на картинке',
    visualCaption: steps.first.caption,
    lessonSteps: steps,
    tasks: tasks,
  );
}

String _pluralItem(String name, int n) {
  if (name == 'апельсин') return n == 1 ? 'апельсинов' : 'апельсинов';
  if (name == 'конфета') return 'конфет';
  if (name == 'звезда') return 'звёзд';
  return name;
}

List<MathNode> _level2() => [
      const MathNode(
        id: 'L2_N1',
        level: 2,
        title: 'Много / мало',
        subtitle: 'На картинках',
        heroLabel: '>',
        emoji: '🍎',
        tipHint: 'Сравни две группы',
        visualCaption: 'Где больше яблок?',
        lessonSteps: [
          MathLessonStep(
            headline: '3 > 2',
            caption: 'Три яблока больше, чем два',
            itemEmoji: '🍎',
            itemCount: 3,
          ),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickLargerGroup,
            prompt: 'Где больше?',
            emoji: '🍎',
            itemEmoji: '🍎',
            left: 3,
            right: 2,
            correctIndex: 0,
          ),
          MathTask(
            type: MathTaskType.dragSign,
            prompt: '3 и 3 — какой знак?',
            left: 3,
            right: 3,
            correctSign: '=',
          ),
        ],
      ),
      const MathNode(
        id: 'L2_N2',
        level: 2,
        title: 'Больше / меньше',
        subtitle: 'Числа',
        heroLabel: '7',
        emoji: '🔢',
        tipHint: 'Сравни два числа',
        visualCaption: '7 больше 4',
        lessonSteps: [
          MathLessonStep(headline: '7 > 4', caption: 'Семь больше четырёх'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickLargerGroup,
            prompt: 'Какое число больше?',
            left: 7,
            right: 4,
            correctIndex: 0,
          ),
          MathTask(
            type: MathTaskType.dragSign,
            prompt: '7 __ 4',
            left: 7,
            right: 4,
            correctSign: '>',
          ),
        ],
      ),
      const MathNode(
        id: 'L2_N3',
        level: 2,
        title: 'Знак >',
        subtitle: 'Больше',
        heroLabel: '>',
        emoji: '📊',
        tipHint: 'Большее число — слева при >',
        visualCaption: 'Большее число слева',
        lessonSteps: [
          MathLessonStep(headline: '>', caption: 'Знак «больше» — как открытый рот к большему числу'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.dragSign,
            prompt: '8 __ 3',
            left: 8,
            right: 3,
            correctSign: '>',
          ),
          MathTask(
            type: MathTaskType.dragSign,
            prompt: '6 __ 2',
            left: 6,
            right: 2,
            correctSign: '>',
          ),
        ],
      ),
      const MathNode(
        id: 'L2_N4',
        level: 2,
        title: 'Знак <',
        subtitle: 'Меньше',
        heroLabel: '<',
        emoji: '📉',
        tipHint: 'Меньшее число — слева при <',
        visualCaption: 'Меньшее число слева',
        lessonSteps: [
          MathLessonStep(headline: '<', caption: 'Знак «меньше» — открытый рот к большему числу'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.dragSign,
            prompt: '2 __ 9',
            left: 2,
            right: 9,
            correctSign: '<',
          ),
          MathTask(
            type: MathTaskType.dragSign,
            prompt: '4 __ 7',
            left: 4,
            right: 7,
            correctSign: '<',
          ),
        ],
      ),
      const MathNode(
        id: 'L2_N5',
        level: 2,
        title: 'Равно =',
        subtitle: 'Столько же',
        heroLabel: '=',
        emoji: '⚖️',
        tipHint: 'Одинаковые числа — знак =',
        visualCaption: 'Одинаковое количество',
        lessonSteps: [
          MathLessonStep(headline: '=', caption: 'Одинаковые числа — знак «равно»'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.dragSign,
            prompt: '5 __ 5',
            left: 5,
            right: 5,
            correctSign: '=',
          ),
          MathTask(
            type: MathTaskType.dragSign,
            prompt: '3 🐟 и 3 🐟 — знак?',
            left: 3,
            right: 3,
            correctSign: '=',
          ),
        ],
      ),
      const MathNode(
        id: 'L2_N6',
        level: 2,
        title: 'Сравни всё',
        subtitle: 'Микс',
        heroLabel: '?',
        emoji: '🎯',
        tipHint: 'Выбери правильный знак',
        visualCaption: 'Три пары чисел',
        lessonSteps: [
          MathLessonStep(headline: '?', caption: 'Выбери знак >, < или = для каждой пары'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.dragSign,
            prompt: '9 __ 5',
            left: 9,
            right: 5,
            correctSign: '>',
          ),
          MathTask(
            type: MathTaskType.dragSign,
            prompt: '1 __ 8',
            left: 1,
            right: 8,
            correctSign: '<',
          ),
          MathTask(
            type: MathTaskType.dragSign,
            prompt: '5 __ 3',
            left: 5,
            right: 3,
            correctSign: '>',
          ),
        ],
      ),
    ];

List<MathNode> _level3() => [
      const MathNode(
        id: 'L3_N1',
        level: 3,
        title: 'Добавить',
        subtitle: 'Визуально +1',
        heroLabel: '+',
        emoji: '🍎',
        tipHint: 'Сложи предметы на картинке',
        visualCaption: '2 яблока + 1 = 3',
        lessonSteps: [
          MathLessonStep(
            headline: '3',
            caption: 'Два яблока и ещё одно — всего три',
            itemEmoji: '🍎',
            itemCount: 3,
            showBasket: true,
          ),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '2 + 1 = ?',
            itemEmoji: '🍎',
            useBasket: true,
            count: 3,
            digit: 3,
            options: [2, 3, 4, 5],
          ),
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '1 + 2 = ?',
            itemEmoji: '🍎',
            useBasket: true,
            count: 3,
            digit: 3,
            options: [2, 3, 4, 5],
          ),
        ],
      ),
      const MathNode(
        id: 'L3_N2',
        level: 3,
        title: 'Сложение до 5',
        subtitle: 'Малые примеры',
        heroLabel: '5',
        emoji: '🌸',
        tipHint: 'Сложи цветы',
        visualCaption: '2 + 3 = 5',
        lessonSteps: [
          MathLessonStep(
            headline: '5',
            caption: 'Два цветка и три цветка — пять',
            itemEmoji: '🌸',
            itemCount: 5,
          ),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '2 + 1 = ?',
            itemEmoji: '🌸',
            count: 3,
            digit: 3,
            options: [2, 3, 4, 5],
          ),
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '2 + 3 = ?',
            itemEmoji: '🌸',
            count: 5,
            digit: 5,
            options: [3, 4, 5, 6],
          ),
        ],
      ),
      const MathNode(
        id: 'L3_N3',
        level: 3,
        title: 'Сложение до 10',
        subtitle: 'Большие примеры',
        heroLabel: '10',
        emoji: '🎈',
        tipHint: 'Сложи группы',
        visualCaption: '4 + 5 = 9',
        lessonSteps: [
          MathLessonStep(
            headline: '9',
            caption: 'Четыре и пять шариков — девять',
            itemEmoji: '🎈',
            itemCount: 9,
          ),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '4 + 5 = ?',
            itemEmoji: '🎈',
            count: 9,
            digit: 9,
            options: [7, 8, 9, 10],
          ),
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '3 + 7 = ?',
            itemEmoji: '🎈',
            count: 10,
            digit: 10,
            options: [8, 9, 10, 11],
          ),
        ],
      ),
      const MathNode(
        id: 'L3_N4',
        level: 3,
        title: 'Сложение на картинке',
        subtitle: '3 + 4',
        heroLabel: '7',
        emoji: '🍊',
        tipHint: 'Посчитай обе группы',
        visualCaption: '3 апельсина + 4 апельсина',
        lessonSteps: [
          MathLessonStep(
            headline: '7',
            caption: 'Три апельсина плюс четыре — семь',
            itemEmoji: '🍊',
            itemCount: 7,
          ),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '3 + 4 = ?',
            itemEmoji: '🍊',
            count: 7,
            digit: 7,
            options: [5, 6, 7, 8],
          ),
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '2 + 5 = ?',
            itemEmoji: '🍊',
            count: 7,
            digit: 7,
            options: [5, 6, 7, 8],
          ),
        ],
      ),
      const MathNode(
        id: 'L3_N5',
        level: 3,
        title: 'Сборка примера',
        subtitle: 'Карточки',
        heroLabel: '7',
        emoji: '🧩',
        tipHint: 'Перетащи числа',
        visualCaption: '_ + _ = 7',
        lessonSteps: [
          MathLessonStep(headline: '7', caption: 'Собери пример: 3 + 4 = 7'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.buildEquation,
            prompt: 'Собери: _ + _ = 7',
            equationParts: [3, 4, 7],
          ),
          MathTask(
            type: MathTaskType.buildEquation,
            prompt: 'Собери: _ + _ = 9',
            equationParts: [4, 5, 9],
          ),
        ],
      ),
      const MathNode(
        id: 'L3_N6',
        level: 3,
        title: 'Пропуск',
        subtitle: 'Найди число',
        heroLabel: '?',
        emoji: '❓',
        tipHint: '4 + ? = 7',
        visualCaption: 'Какое число пропущено?',
        lessonSteps: [
          MathLessonStep(headline: '?', caption: '4 + ? = 7 — найди пропущенное число'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.fillBlank,
            prompt: '4 + ? = 7',
            digit: 3,
            options: [2, 3, 4, 5],
          ),
          MathTask(
            type: MathTaskType.fillBlank,
            prompt: '5 + ? = 8',
            digit: 3,
            options: [1, 2, 3, 4],
          ),
        ],
      ),
      const MathNode(
        id: 'L3_N7',
        level: 3,
        title: 'Смешанное сложение',
        subtitle: 'Несколько примеров',
        heroLabel: '5',
        emoji: '➕',
        tipHint: 'Реши каждый пример',
        visualCaption: 'Сложи числа',
        lessonSteps: [
          MathLessonStep(headline: '+', caption: 'Реши примеры на сложение'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '3 + 2 = ?',
            digit: 5,
            options: [3, 4, 5, 6],
          ),
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '1 + 6 = ?',
            digit: 7,
            options: [5, 6, 7, 8],
          ),
        ],
      ),
    ];

List<MathNode> _level4() => [
      const MathNode(
        id: 'L4_N1',
        level: 4,
        title: 'Убрали',
        subtitle: 'Минус на картинке',
        heroLabel: '−',
        emoji: '🍪',
        tipHint: 'Убери предметы — посчитай остаток',
        visualCaption: '5 − 2 = 3',
        lessonSteps: [
          MathLessonStep(
            headline: '3',
            caption: 'Было 5 печений, убрали 2 — осталось 3',
            itemEmoji: '🍪',
            itemCount: 3,
          ),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '5 − 2 = ?',
            itemEmoji: '🍪',
            count: 3,
            digit: 3,
            options: [2, 3, 4, 5],
          ),
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '7 − 3 = ?',
            digit: 4,
            options: [2, 3, 4, 5],
          ),
        ],
      ),
      const MathNode(
        id: 'L4_N2',
        level: 4,
        title: 'Вычитание до 5',
        subtitle: 'Малые примеры',
        heroLabel: '3',
        emoji: '🍭',
        tipHint: '4 − 1 = 3',
        visualCaption: 'Убери конфеты',
        lessonSteps: [
          MathLessonStep(
            headline: '3',
            caption: 'Четыре конфеты, одну убрали — три',
            itemEmoji: '🍭',
            itemCount: 3,
          ),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '4 − 1 = ?',
            digit: 3,
            options: [2, 3, 4, 5],
          ),
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '5 − 2 = ?',
            digit: 3,
            options: [1, 2, 3, 4],
          ),
        ],
      ),
      const MathNode(
        id: 'L4_N3',
        level: 4,
        title: 'Вычитание до 10',
        subtitle: 'Большие примеры',
        heroLabel: '4',
        emoji: '🎁',
        tipHint: '9 − 4 = 5',
        visualCaption: 'Сложные примеры',
        lessonSteps: [
          MathLessonStep(headline: '−', caption: 'Вычитай меньшее число из большего'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '9 − 4 = ?',
            digit: 5,
            options: [4, 5, 6, 7],
          ),
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '10 − 6 = ?',
            digit: 4,
            options: [2, 3, 4, 5],
          ),
        ],
      ),
      const MathNode(
        id: 'L4_N4',
        level: 4,
        title: 'Сборка (−)',
        subtitle: 'Карточки',
        heroLabel: '5',
        emoji: '🧩',
        tipHint: '9 − 4 = 5',
        visualCaption: 'Собери пример',
        lessonSteps: [
          MathLessonStep(headline: '5', caption: '9 − 4 = 5 — поставь числа'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.buildEquation,
            prompt: 'Собери: 9 − 4 = _',
            equationParts: [9, 4, 5],
          ),
        ],
      ),
      const MathNode(
        id: 'L4_N5',
        level: 4,
        title: 'Круг · Квадрат · ▲',
        subtitle: 'Фигуры',
        heroLabel: '○',
        emoji: '🔷',
        tipHint: 'Круг — без углов',
        visualCaption: 'Найди круг',
        lessonSteps: [
          MathLessonStep(headline: '○', caption: 'Круг — круглый, без углов'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickShape,
            prompt: 'Найди круг',
            shape: MathShape.circle,
          ),
          MathTask(
            type: MathTaskType.pickShape,
            prompt: 'Найди треугольник',
            shape: MathShape.triangle,
          ),
        ],
      ),
      const MathNode(
        id: 'L4_N6',
        level: 4,
        title: 'Найди фигуру',
        subtitle: 'Среди других',
        heroLabel: '□',
        emoji: '🏠',
        tipHint: 'Квадрат — окно домика',
        visualCaption: 'Фигура в предмете',
        lessonSteps: [
          MathLessonStep(headline: '▲', caption: 'Крыша домика — треугольник'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickShape,
            prompt: 'Крыша домика — какая фигура?',
            shape: MathShape.triangle,
          ),
          MathTask(
            type: MathTaskType.pickShape,
            prompt: 'Окно — какая фигура?',
            shape: MathShape.square,
          ),
        ],
      ),
      const MathNode(
        id: 'L4_N7',
        level: 4,
        title: 'Собери домик',
        subtitle: 'Пазл фигур',
        heroLabel: '🏠',
        emoji: '🧱',
        tipHint: '▲ + □ + ▭',
        visualCaption: 'Перетащи фигуры',
        lessonSteps: [
          MathLessonStep(headline: '🏠', caption: 'Собери домик из фигур'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.dragOrder,
            prompt: 'Собери домик сверху вниз',
            orderItems: ['▲', '□', '▭'],
          ),
        ],
      ),
      const MathNode(
        id: 'L4_N8',
        level: 4,
        title: 'Что дальше?',
        subtitle: 'Паттерны',
        heroLabel: '▲',
        emoji: '🔁',
        tipHint: 'Продолжи ряд',
        visualCaption: '● ▲ ● ▲ ● ?',
        lessonSteps: [
          MathLessonStep(headline: '▲', caption: 'Продолжи ряд: чередуются круг и треугольник'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickPattern,
            prompt: '● ▲ ● ▲ ● ?',
            pattern: ['●', '▲', '●', '▲', '●', '▲'],
          ),
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '2, 4, 6, ?',
            digit: 8,
            options: [6, 7, 8, 9],
          ),
        ],
      ),
    ];

List<MathNode> _level5() => [
      const MathNode(
        id: 'L5_N1',
        level: 5,
        title: 'Монеты',
        subtitle: '5₽ + 5₽',
        heroLabel: '10',
        emoji: '🪙',
        tipHint: 'Сложи монеты',
        visualCaption: 'Сложи монеты',
        lessonSteps: [
          MathLessonStep(headline: '10₽', caption: '5 рублей + 5 рублей = 10'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '5₽ + 5₽ = ?',
            emoji: '🪙🪙',
            digit: 10,
            options: [8, 9, 10, 11],
          ),
        ],
      ),
      const MathNode(
        id: 'L5_N2',
        level: 5,
        title: 'Покупка',
        subtitle: 'Хватит ли?',
        heroLabel: '?',
        emoji: '🍦',
        tipHint: 'Сравни цену и деньги',
        visualCaption: 'Мороженое 15₽, есть 10₽',
        lessonSteps: [
          MathLessonStep(headline: '10₽', caption: '10 рублей — не хватит на 15'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.yesNo,
            prompt: '15₽, есть 10₽ — хватит?',
            correctIndex: 0,
          ),
        ],
      ),
      const MathNode(
        id: 'L5_N3',
        level: 5,
        title: 'Сдача',
        subtitle: '10₽ − 7₽',
        heroLabel: '3',
        emoji: '💰',
        tipHint: 'Посчитай сдачу',
        visualCaption: 'Дал 10₽, цена 7₽',
        lessonSteps: [
          MathLessonStep(headline: '3₽', caption: '10 − 7 = 3 рубля сдачи'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: 'Сдача: 10 − 7 = ?',
            emoji: '💰',
            digit: 3,
            options: [2, 3, 4, 5],
          ),
        ],
      ),
      const MathNode(
        id: 'L5_N4',
        level: 5,
        title: 'Часы',
        subtitle: 'Целые часы',
        heroLabel: '3',
        emoji: '🕒',
        tipHint: 'Посмотри на стрелки',
        visualCaption: 'Стрелки на 3:00',
        lessonSteps: [
          MathLessonStep(headline: '3', caption: 'Большая стрелка на цифре 3 — три часа'),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: 'Который час? (3:00)',
            emoji: '🕒',
            digit: 3,
            options: [1, 2, 3, 4],
          ),
        ],
      ),
      const MathNode(
        id: 'L5_N5',
        level: 5,
        title: 'Распорядок дня',
        subtitle: 'Утро → обед → вечер',
        heroLabel: '☀️',
        emoji: '📅',
        tipHint: 'Порядок событий',
        visualCaption: 'Расставь по порядку',
        lessonSteps: [
          MathLessonStep(
            headline: '☀️',
            caption: 'Утро → обед → вечер',
            itemEmoji: '🌅',
          ),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.dragOrder,
            prompt: 'Утро → обед → вечер',
            orderItems: ['🌅', '🍽️', '🌙'],
          ),
        ],
      ),
      const MathNode(
        id: 'L5_N6',
        level: 5,
        title: 'Финальный квест',
        subtitle: '5 навыков',
        heroLabel: '🏆',
        emoji: '🎯',
        tipHint: 'Всё вместе',
        visualCaption: 'Задача-история',
        lessonSteps: [
          MathLessonStep(
            headline: '3',
            caption: '5 печений, съел 2 — осталось 3',
            itemEmoji: '🍪',
            itemCount: 3,
          ),
        ],
        tasks: [
          MathTask(
            type: MathTaskType.pickDigit,
            prompt: '5 печенек, съел 2 — осталось?',
            itemEmoji: '🍪',
            count: 3,
            digit: 3,
            options: [2, 3, 4, 5],
          ),
          MathTask(
            type: MathTaskType.dragSign,
            prompt: '10 __ 6',
            left: 10,
            right: 6,
            correctSign: '>',
          ),
          MathTask(
            type: MathTaskType.pickShape,
            prompt: 'Монета — какая форма?',
            shape: MathShape.circle,
          ),
        ],
      ),
    ];
