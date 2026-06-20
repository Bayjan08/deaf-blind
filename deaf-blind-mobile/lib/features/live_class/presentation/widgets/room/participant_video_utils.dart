import 'package:livekit_client/livekit_client.dart';

/// Helpers for resolving participant video tracks.
VideoTrack? cameraTrackFor(Participant participant) {
  final isLocal = participant is LocalParticipant;

  for (final pub in participant.videoTrackPublications) {
    if (pub.source == TrackSource.screenShareVideo) continue;
    if (pub.track == null) continue;
    // Local tracks are available immediately; remote tracks require subscription.
    if (!isLocal && !pub.subscribed) continue;
    final track = pub.track;
    if (track is VideoTrack) return track;
  }
  return null;
}

VideoTrack? screenShareTrack(Room? room) {
  if (room == null) return null;

  for (final p in room.remoteParticipants.values) {
    for (final pub in p.videoTrackPublications) {
      if (pub.source == TrackSource.screenShareVideo && pub.track is VideoTrack) {
        return pub.track as VideoTrack;
      }
    }
  }

  final local = room.localParticipant;
  if (local != null) {
    for (final pub in local.videoTrackPublications) {
      if (pub.source == TrackSource.screenShareVideo && pub.track is VideoTrack) {
        return pub.track as VideoTrack;
      }
    }
  }
  return null;
}
