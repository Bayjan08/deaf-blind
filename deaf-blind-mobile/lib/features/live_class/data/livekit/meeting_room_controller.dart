import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/models/meeting.dart';
import '../../domain/models/meeting_room_phase.dart';
import '../mappers/meeting_error_mapper.dart';
import 'meeting_room_listener.dart';

/// Manages LiveKit room connection, tracks, and in-call controls.
class MeetingRoomController extends ChangeNotifier {
  MeetingRoomController();

  Room? _room;
  MeetingRoomListener? _roomListener;
  MeetingRoomPhase _phase = MeetingRoomPhase.idle;
  String? _errorMessage;
  bool _micEnabled = true;
  bool _cameraEnabled = true;
  bool _speakerEnabled = true;
  bool _screenShareEnabled = false;
  CameraPosition _cameraPosition = CameraPosition.front;
  ConnectionQuality _connectionQuality = ConnectionQuality.unknown;
  String? _activeSpeakerIdentity;

  Room? get room => _room;
  MeetingRoomPhase get phase => _phase;
  String? get errorMessage => _errorMessage;
  bool get micEnabled => _micEnabled;
  bool get cameraEnabled => _cameraEnabled;
  bool get speakerEnabled => _speakerEnabled;
  bool get screenShareEnabled => _screenShareEnabled;
  ConnectionQuality get connectionQuality => _connectionQuality;
  String? get activeSpeakerIdentity => _activeSpeakerIdentity;

  /// Shown when camera could not be enabled after joining.
  String? get cameraStatusHint {
    if (_cameraEnabled || _phase != MeetingRoomPhase.connected) return null;
    return 'Камера недоступна. На iOS Simulator камера не работает — запустите на iPhone или включите камеру в настройках симулятора (Features → Camera).';
  }

  List<Participant> get remoteParticipants =>
      _room?.remoteParticipants.values.toList() ?? const [];

  int get participantCount => (_room?.remoteParticipants.length ?? 0) + 1;

  Future<void> connect(MeetingConnection connection) async {
    _phase = MeetingRoomPhase.connecting;
    _errorMessage = null;
    notifyListeners();

    if (!await _ensurePermissions()) {
      _phase = MeetingRoomPhase.error;
      _errorMessage = 'Нужен доступ к камере или микрофону';
      notifyListeners();
      return;
    }

    try {
      _room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultCameraCaptureOptions: CameraCaptureOptions(
            cameraPosition: CameraPosition.front,
          ),
        ),
      );
      _roomListener = MeetingRoomListener(this)..attach(_room!);

      final livekitUrl = connection.livekitUrl;
      debugPrint('[LiveKit] connecting to $livekitUrl room=${connection.meeting.id}');

      await _room!.prepareConnection(livekitUrl, connection.token);
      await _room!.connect(livekitUrl, connection.token);

      // Mic and camera are enabled independently — camera often fails on iOS
      // Simulator even when permissions are granted (LiveKit SDK note).
      var publishedAny = false;

      try {
        await _room!.localParticipant?.setCameraEnabled(true);
        _cameraEnabled = true;
        publishedAny = true;
      } catch (e) {
        debugPrint('Camera unavailable: $e');
        _cameraEnabled = false;
      }

      try {
        await _room!.localParticipant?.setMicrophoneEnabled(true);
        _micEnabled = true;
        publishedAny = true;
      } catch (e) {
        debugPrint('Microphone unavailable: $e');
        _micEnabled = false;
      }

      if (!publishedAny) {
        // iOS Simulator often has no camera/mic hardware — still allow
        // receive-only mode so you can test with a second client on a real device.
        debugPrint('Joining in receive-only mode (no local tracks published)');
        _micEnabled = false;
        _cameraEnabled = false;
      }

      await Hardware.instance.setSpeakerphoneOn(true);
      _speakerEnabled = true;
      _phase = MeetingRoomPhase.connected;
      notifyListeners();
    } catch (e) {
      _phase = MeetingRoomPhase.error;
      _errorMessage = MeetingErrorMapper.fromLivekit(e.toString());
      notifyListeners();
      await _safeDisconnect();
    }
  }

  Future<bool> _ensurePermissions() async {
    if (kIsWeb) return true;
    final camera = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    return camera.isGranted || mic.isGranted;
  }

  void onDisconnected(String reason) {
    _phase = MeetingRoomPhase.disconnected;
    _errorMessage = MeetingErrorMapper.fromLivekit(reason);
    notifyListeners();
  }

  void onReconnecting() {
    _phase = MeetingRoomPhase.reconnecting;
    notifyListeners();
  }

  void onReconnected() {
    _phase = MeetingRoomPhase.connected;
    notifyListeners();
  }

  void onParticipantsChanged() => notifyListeners();

  void onActiveSpeakerChanged(String? identity) {
    _activeSpeakerIdentity = identity;
    notifyListeners();
  }

  void onConnectionQualityChanged(ConnectionQuality quality) {
    if (_connectionQuality == quality) return;
    _connectionQuality = quality;
    notifyListeners();
  }

  Future<void> toggleMicrophone() async {
    final local = _room?.localParticipant;
    if (local == null) return;
    final next = !_micEnabled;
    try {
      await local.setMicrophoneEnabled(next);
      _micEnabled = next;
    } catch (e) {
      debugPrint('Could not toggle microphone: $e');
      _micEnabled = false;
    }
    notifyListeners();
  }

  Future<void> toggleCamera() async {
    final local = _room?.localParticipant;
    if (local == null) return;
    final next = !_cameraEnabled;
    try {
      await local.setCameraEnabled(next);
      _cameraEnabled = next;
    } catch (e) {
      debugPrint('Could not toggle camera: $e');
      _cameraEnabled = false;
    }
    notifyListeners();
  }

  Future<void> switchCamera() async {
    final local = _room?.localParticipant;
    if (local == null) return;
    _cameraPosition = _cameraPosition == CameraPosition.front
        ? CameraPosition.back
        : CameraPosition.front;

    for (final pub in local.videoTrackPublications) {
      final track = pub.track;
      if (track is LocalVideoTrack) {
        await track.setCameraPosition(_cameraPosition);
        break;
      }
    }
    notifyListeners();
  }

  Future<void> toggleSpeaker() async {
    _speakerEnabled = !_speakerEnabled;
    await Hardware.instance.setSpeakerphoneOn(_speakerEnabled);
    notifyListeners();
  }

  bool get screenShareSupported =>
      kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  Future<void> toggleScreenShare() async {
    if (!screenShareSupported) return;
    final local = _room?.localParticipant;
    if (local == null) return;
    _screenShareEnabled = !_screenShareEnabled;
    try {
      await local.setScreenShareEnabled(_screenShareEnabled);
    } catch (e) {
      debugPrint('Screen share unavailable: $e');
      _screenShareEnabled = false;
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _safeDisconnect();
    _roomListener?.dispose();
    _roomListener = null;
    _room = null;
    _phase = MeetingRoomPhase.idle;
    notifyListeners();
  }

  Future<void> _safeDisconnect() async {
    final room = _room;
    if (room == null) return;
    try {
      await room.disconnect().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[LiveKit] disconnect ignored: $e');
    }
  }

  @override
  void dispose() {
    _roomListener?.dispose();
    final room = _room;
    _room = null;
    if (room != null) {
      unawaited(_safeDisconnect());
    }
    super.dispose();
  }
}
