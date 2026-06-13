import 'dart:async';

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

  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;
  StreamSubscription<void>? _becomingNoisySubscription;

  // ── Inicialización de background audio (lazy, one-shot) ────────────────
  //
  // JustAudioBackground.init() reemplaza JustAudioPlatform.instance con
  // _JustAudioBackgroundPlugin y luego inicia _audioHandler via
  // AudioService.init() (async). Si setAudioSource() se llama ANTES de que
  // AudioService.init() complete, el constructor _JustAudioPlayer accede a
  // _audioHandler (campo late) que no fue asignado → LateInitializationError.
  // Peor aún: _playerId queda seteado pero _platformValue sigue siendo
  // _IdleAudioPlayer, así que stop() no llama disposePlayer() y _playerId
  // nunca se resetea → próximo init() lanza "single player instance".
  //
  // Solución: inicializar aquí, bloqueante, ANTES de cualquier
  // setAudioSource(). Cuando play() se invoca el Activity ya está en
  // foreground, así que AudioService.init() se conecta sin problema.

  static Future<void>? _bgInitFuture;

  static Future<void> _ensureBackgroundInit() {
    return _bgInitFuture ??= _doBackgroundInit();
  }

  static Future<void> _doBackgroundInit() async {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.latinterritory.radio.channel',
      androidNotificationChannelName: 'Latin Territory Radio',
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    );
    debugPrint('[RadioPlayer] JustAudioBackground inicializado.');
  }

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

    // Bloquear hasta que _audioHandler esté listo. Cuando el usuario
    // interactúa el Activity está en foreground, así que este await
    // completa en < 200 ms en el primer llamado.
    await _ensureBackgroundInit();

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
    await _interruptionSubscription?.cancel();
    await _becomingNoisySubscription?.cancel();
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

      _interruptionSubscription =
          session.interruptionEventStream.listen((event) {
        if (event.begin) {
          if (event.type == AudioInterruptionType.pause ||
              event.type == AudioInterruptionType.duck) {
            _player.pause();
            debugPrint('[RadioPlayer] Interrupción iniciada (${event.type}) — pausando.');
          }
        } else {
          if (event.type == AudioInterruptionType.pause) {
            _player.play();
            debugPrint('[RadioPlayer] Interrupción terminada — reanudando.');
          }
        }
      });

      _becomingNoisySubscription =
          session.becomingNoisyEventStream.listen((_) {
        _player.pause();
        debugPrint('[RadioPlayer] Becoming noisy (audífonos desconectados) — pausando.');
      });

      _sessionConfigured = true;
      debugPrint('[RadioPlayer] AudioSession configurada correctamente.');
    } catch (e) {
      debugPrint('[RadioPlayer] Error configurando AudioSession: $e');
    }
  }
}
