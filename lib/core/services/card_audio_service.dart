import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../database/media_storage_service.dart';

/// Centralized audio service for flashcard playback.
///
/// Ensures a single native [AudioPlayer] instance is reused across card transitions,
/// preventing native Android MediaPlayer exhaustion and audio focus conflicts.
class CardAudioService {
  static CardAudioService? _instance;

  final AudioPlayer _player;
  final ValueNotifier<String?> _playingFilenameNotifier =
      ValueNotifier<String?>(null);
  StreamSubscription<void>? _completeSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;

  CardAudioService._({AudioPlayer? player})
    : _player = player ?? AudioPlayer() {
    _initSubscriptions();
  }

  static CardAudioService get instance {
    _instance ??= CardAudioService._();
    return _instance!;
  }

  @visibleForTesting
  static void setMockInstance(CardAudioService service) {
    _instance = service;
  }

  @visibleForTesting
  static void resetInstance() {
    _instance?.dispose();
    _instance = null;
  }

  AudioPlayer get player => _player;

  /// Notifier exposing the currently playing raw media filename (or null if idle).
  ValueListenable<String?> get playingFilenameNotifier =>
      _playingFilenameNotifier;

  /// Current playing filename.
  String? get currentPlayingFilename => _playingFilenameNotifier.value;

  void _initSubscriptions() {
    _completeSubscription = _player.onPlayerComplete.listen((_) {
      _playingFilenameNotifier.value = null;
    });

    _stateSubscription = _player.onPlayerStateChanged.listen((state) {
      if (state != PlayerState.playing) {
        if (_playingFilenameNotifier.value != null &&
            state != PlayerState.paused) {
          _playingFilenameNotifier.value = null;
        }
      }
    });
  }

  /// Initialize global audio session and Android focus preferences.
  Future<void> init() async {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: true,
            contentType: AndroidContentType.speech,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {AVAudioSessionOptions.duckOthers},
          ),
        ),
      );
    } catch (e) {
      debugPrint('[CardAudioService] Failed to set global AudioContext: $e');
    }
  }

  /// Play flashcard media by filename or sound tag.
  ///
  /// Resolves the file via [MediaStorageService.resolveMediaFile], handling
  /// URL-encoding, quotes, and case-insensitivity on Android ext4/f2fs filesystems.
  Future<void> playMedia(String rawFilename) async {
    final trimmed = rawFilename.trim();
    if (trimmed.isEmpty) return;

    final file = MediaStorageService.instance.resolveMediaFile(trimmed);
    if (file == null || !file.existsSync()) {
      debugPrint('[CardAudioService] Media file not found for: "$trimmed"');
      _playingFilenameNotifier.value = null;
      return;
    }

    await playFile(file, filename: trimmed);
  }

  /// Plays a direct [File] with error handling and state tracking.
  Future<void> playFile(File file, {String? filename}) async {
    try {
      // Stop previous playback to release native buffers safely
      await _player.stop();
      _playingFilenameNotifier.value = filename ?? file.path;
      await _player.play(DeviceFileSource(file.path));
    } catch (e, st) {
      debugPrint('[CardAudioService] Error playing ${file.path}: $e\n$st');
      _playingFilenameNotifier.value = null;
    }
  }

  /// Stops current playback if any is active.
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('[CardAudioService] Error stopping audio: $e');
    } finally {
      _playingFilenameNotifier.value = null;
    }
  }

  /// Release subscriptions and underlying audio player.
  void dispose() {
    _completeSubscription?.cancel();
    _stateSubscription?.cancel();
    _player.dispose();
  }
}
