import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Singleton que gestiona la reproducción de streams de radio.
///
/// Persiste entre pantallas — el audio continúa aunque el usuario
/// navegue a otras secciones de la app.
class RadioPlayerService {
  RadioPlayerService._();
  static final RadioPlayerService instance = RadioPlayerService._();

  final AudioPlayer _player = AudioPlayer();
  bool _sessionConfigured = false;

  // ── Estado reactivo ────────────────────────────────────

  /// Stream del estado de reproducción (true = reproduciendo).
  Stream<bool> get isPlayingStream => _player.playingStream;

  /// Valor sincrónico del estado de reproducción.
  bool get isPlaying => _player.playing;

  // ── Operaciones ────────────────────────────────────────

  /// Inicia o cambia el stream al [streamUrl] dado.
  Future<void> play(String streamUrl) async {
    try {
      await _configureSession();
      await _player.stop();
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(streamUrl)),
        preload: false,
      );
      await _player.play();
    } on PlayerException catch (e) {
      debugPrint('[RadioPlayer] PlayerException: ${e.message}');
      rethrow;
    } on PlayerInterruptedException catch (e) {
      debugPrint('[RadioPlayer] Interrupted: ${e.message}');
    } catch (e) {
      debugPrint('[RadioPlayer] Unexpected error: $e');
      rethrow;
    }
  }

  /// Detiene la reproducción sin liberar el servicio.
  Future<void> stop() async {
    await _player.stop();
  }

  /// Libera todos los recursos — llamar solo al cerrar la app.
  Future<void> dispose() async {
    await _player.dispose();
  }

  // ── Configuración de sesión iOS/Android ────────────────

  Future<void> _configureSession() async {
    if (_sessionConfigured) return;
    _sessionConfigured = true;

    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions:
            AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ),
    );
  }
}
