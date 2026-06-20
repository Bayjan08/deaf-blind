import '../domain/models/gesture_card.dart';

const String _signsDir = 'assets/images/signs';

/// 25 hardcoded sign-language gestures, sourced from a sign-language
/// flashcard reference (picture kept as in the source; meaning in Russian).
List<GestureCard> buildGestureCardCatalog() => [
      GestureCard(id: 1, meaning: 'Все', imageAsset: '$_signsDir/all_done.png'),
      GestureCard(id: 2, meaning: 'Не надо', imageAsset: '$_signsDir/dont.png'),
      GestureCard(id: 3, meaning: 'Кушать', imageAsset: '$_signsDir/eat.png'),
      GestureCard(id: 4, meaning: 'Друзья', imageAsset: '$_signsDir/friends.png'),
      GestureCard(id: 5, meaning: 'Помощь', imageAsset: '$_signsDir/help.png'),
      GestureCard(id: 6, meaning: 'Привет', imageAsset: '$_signsDir/hello.png'),
      GestureCard(id: 7, meaning: 'Голодный', imageAsset: '$_signsDir/hungry.png'),
      GestureCard(id: 8, meaning: 'Нравится', imageAsset: '$_signsDir/like.png'),
      GestureCard(id: 9, meaning: 'Я', imageAsset: '$_signsDir/me.png'),
      GestureCard(id: 10, meaning: 'Ещё', imageAsset: '$_signsDir/more.png'),
      GestureCard(id: 11, meaning: 'Нет', imageAsset: '$_signsDir/no.png'),
      GestureCard(id: 12, meaning: 'Играть', imageAsset: '$_signsDir/play.png'),
      GestureCard(id: 13, meaning: 'Пожалуйста', imageAsset: '$_signsDir/please.png'),
      GestureCard(id: 14, meaning: 'Стоп', imageAsset: '$_signsDir/stop.png'),
      GestureCard(id: 15, meaning: 'Спасибо', imageAsset: '$_signsDir/thank_you.png'),
      GestureCard(id: 16, meaning: 'Туалет', imageAsset: '$_signsDir/toilet.png'),
      GestureCard(id: 17, meaning: 'Хочу', imageAsset: '$_signsDir/want.png'),
      GestureCard(id: 18, meaning: 'Вода', imageAsset: '$_signsDir/water.png'),
      GestureCard(id: 19, meaning: 'Что', imageAsset: '$_signsDir/what.png'),
      GestureCard(id: 20, meaning: 'Когда', imageAsset: '$_signsDir/when.png'),
      GestureCard(id: 21, meaning: 'Где', imageAsset: '$_signsDir/where.png'),
      GestureCard(id: 22, meaning: 'Кто', imageAsset: '$_signsDir/who.png'),
      GestureCard(id: 23, meaning: 'Почему', imageAsset: '$_signsDir/why.png'),
      GestureCard(id: 24, meaning: 'Да', imageAsset: '$_signsDir/yes.png'),
      GestureCard(id: 25, meaning: 'Ты', imageAsset: '$_signsDir/you.png'),
    ];
