import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import 'participant_tile.dart';
import 'participant_video_utils.dart';

class ParticipantGrid extends StatelessWidget {
  const ParticipantGrid({
    super.key,
    required this.room,
    required this.activeSpeakerIdentity,
  });

  final Room room;
  final String? activeSpeakerIdentity;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      if (room.localParticipant != null)
        ParticipantTile(
          participant: room.localParticipant!,
          isLocal: true,
          highlighted: activeSpeakerIdentity == room.localParticipant!.identity,
        ),
      ...room.remoteParticipants.values.map(
        (p) => ParticipantTile(
          participant: p,
          isLocal: false,
          highlighted: activeSpeakerIdentity == p.identity,
        ),
      ),
    ];

    final crossCount = tiles.length <= 2 ? 1 : tiles.length <= 4 ? 2 : 3;

    return GridView.count(
      crossAxisCount: crossCount,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: tiles,
    );
  }
}

class MeetingVideoStage extends StatelessWidget {
  const MeetingVideoStage({
    super.key,
    required this.room,
    required this.remotes,
    required this.activeSpeakerIdentity,
  });

  final Room? room;
  final List<Participant> remotes;
  final String? activeSpeakerIdentity;

  @override
  Widget build(BuildContext context) {
    final screenTrack = screenShareTrack(room);
    final oneToOne = remotes.length <= 1;

    if (screenTrack != null) {
      return Positioned.fill(child: VideoTrackRenderer(screenTrack));
    }

    // Alone in the room — show your own camera/placeholder full screen.
    if (remotes.isEmpty && room?.localParticipant != null) {
      return Positioned.fill(
        child: ParticipantTile(
          participant: room!.localParticipant!,
          isLocal: true,
          highlighted: true,
        ),
      );
    }

    if (oneToOne && remotes.isNotEmpty) {
      return Positioned.fill(
        child: ParticipantTile(
          participant: remotes.first,
          isLocal: false,
          highlighted: activeSpeakerIdentity == remotes.first.identity,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 110, 12, 130),
      child: ParticipantGrid(room: room!, activeSpeakerIdentity: activeSpeakerIdentity),
    );
  }
}

class LocalPreviewTile extends StatelessWidget {
  const LocalPreviewTile({super.key, required this.participant});

  final Participant participant;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 150,
      child: ParticipantTile(participant: participant, isLocal: true, compact: true),
    );
  }
}
