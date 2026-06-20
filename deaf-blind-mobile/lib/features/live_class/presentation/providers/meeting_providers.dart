import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/meeting_remote_source.dart';
import '../../data/livekit/meeting_room_controller.dart';
import '../../data/repositories/meeting_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final meetingRepositoryProvider = Provider<MeetingRepository>((ref) {
  return MeetingRepository(MeetingRemoteSource(ref.watch(apiClientProvider)));
});

final meetingRoomControllerProvider =
    ChangeNotifierProvider.autoDispose<MeetingRoomController>(
  (ref) => MeetingRoomController(),
);
