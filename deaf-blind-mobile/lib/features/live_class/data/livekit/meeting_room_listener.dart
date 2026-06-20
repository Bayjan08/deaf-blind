import 'package:livekit_client/livekit_client.dart';

import 'meeting_room_controller.dart';

/// Wires LiveKit room events to [MeetingRoomController].
class MeetingRoomListener {
  MeetingRoomListener(this._controller);

  final MeetingRoomController _controller;
  EventsListener<RoomEvent>? _listener;

  void attach(Room room) {
    dispose();
    _listener = room.createListener()
      ..on<RoomDisconnectedEvent>((event) {
        _controller.onDisconnected(event.reason.toString());
      })
      ..on<RoomReconnectingEvent>((_) => _controller.onReconnecting())
      ..on<RoomReconnectedEvent>((_) => _controller.onReconnected())
      ..on<ParticipantConnectedEvent>((_) => _controller.onParticipantsChanged())
      ..on<ParticipantDisconnectedEvent>((_) => _controller.onParticipantsChanged())
      ..on<LocalTrackPublishedEvent>((_) => _controller.onParticipantsChanged())
      ..on<LocalTrackUnpublishedEvent>((_) => _controller.onParticipantsChanged())
      ..on<TrackPublishedEvent>((_) => _controller.onParticipantsChanged())
      ..on<TrackSubscribedEvent>((_) => _controller.onParticipantsChanged())
      ..on<TrackUnsubscribedEvent>((_) => _controller.onParticipantsChanged())
      ..on<ActiveSpeakersChangedEvent>((event) {
        _controller.onActiveSpeakerChanged(
          event.speakers.isNotEmpty ? event.speakers.first.identity : null,
        );
      })
      ..on<ParticipantConnectionQualityUpdatedEvent>((event) {
        if (event.participant is LocalParticipant) {
          _controller.onConnectionQualityChanged(event.connectionQuality);
        }
      });
  }

  void dispose() {
    _listener?.dispose();
    _listener = null;
  }
}
