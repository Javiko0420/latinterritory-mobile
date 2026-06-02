import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// Singleton que gestiona la reproducción de streams de radio.
///
/// Persiste entre pantallas — el audio continúa aunque el usuario
/// navegue a otras secciones de la app o bloquee el teléfono.
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
  ///
  /// [title], [artist] y [artUri] se usan en la notificación de
  /// pantalla de bloqueo y en el centro de medios del sistema.
  Future<void> play(
    String streamUrl, {
    String title = 'Latin Territory Radio',
    String? artist,
    Uri? artUri,
  }) async {
    await _configureSession();

    await _player.stop();

    await _player.setAudioSource(
      AudioSource.uri(
        Uri.parse(streamUrl),
        tag: MediaItem(
          id: streamUrl,
          title: title,
          artist: artist,
          artUri: artUri,
          displayTitle: title,
          displaySubtitle: artist,
        ),
      ),
    );

    await _player.play();
  }

  /// Detiene la reproducción sin liberar el servicio.
  Future<void> stop() async {
    await _player.stop();
  }

  /// Pausa la reproducción manteniendo la fuente cargada.
  Future<void> pause() async {
    await _player.pause();
  }

  /// Reanuda la reproducción tras una pausa.
  Future<void> resume() async {
    await _player.play();
  }

  /// Libera todos los recursos — llamar solo al cerrar la app.
  Future<void> dispose() async {
    await _player.dispose();
  }

  // ── Configuración de sesión iOS/Android ────────────────

  Future<void> _configureSession() async {
    if (_sessionConfigured) return;

    try {
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.longFormAudio,
          avAudioSessionSetActiveOptions:
              AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.media,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: false,
        ),
      );
      _sessionConfigured = true;
      debugPrint('[RadioPlayer] AudioSession configurada correctamente.');
    } catch (e) {
      debugPrint('[RadioPlayer] Error configurando AudioSession: $e');
    }
  }
}
