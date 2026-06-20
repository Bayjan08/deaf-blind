import 'package:dio/dio.dart';

/// Maps API / network errors to user-facing Russian messages.
class MeetingErrorMapper {
  const MeetingErrorMapper._();

  static String from(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final detail = _detailMessage(error.response?.data);

      if (status == 404 || detail.contains('Invalid meeting')) {
        return 'Неверный код встречи';
      }
      if (status == 410 || detail.contains('ended')) {
        return 'Встреча уже завершена';
      }
      if (status == 401 || status == 403) {
        return 'Ошибка авторизации';
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return 'Не удалось подключиться к серверу';
      }
    }

    final msg = error.toString();
    if (msg.contains('404') || msg.contains('Invalid meeting')) {
      return 'Неверный код встречи';
    }
    if (msg.contains('410') || msg.contains('ended')) {
      return 'Встреча уже завершена';
    }
    if (msg.contains('401') || msg.contains('403')) {
      return 'Ошибка авторизации';
    }
    if (msg.contains('SocketException') || msg.contains('connection')) {
      return 'Не удалось подключиться к серверу';
    }
    return 'Ошибка: $error';
  }

  static String _detailMessage(Object? data) {
    if (data is Map && data['detail'] is String) {
      return data['detail'] as String;
    }
    return '';
  }
}
