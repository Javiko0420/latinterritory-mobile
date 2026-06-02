import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/features/radio/data/models/radio_models.dart'
    as api;
import 'package:latinterritory/features/radio/data/radio_station.dart';
import 'package:latinterritory/features/radio/providers/radio_providers.dart';
import 'package:latinterritory/features/radio/services/radio_player_service.dart';

enum RadioPlayerMode { expanded, minimized, hidden }

class RadioPlayerState {
  final RadioPlayerMode mode;
  final int stationIndex;
  final bool isPlaying;
  final Offset position;
  final List<LatinRadioStation> playlist;

  final List<api.RadioStation>? apiStations;

  const RadioPlayerState({
    this.mode = RadioPlayerMode.hidden,
    this.stationIndex = 0,
    this.isPlaying = false,
    this.position = const Offset(16, 600),
    this.playlist = kLatinStations,
    this.apiStations,
  });

  LatinRadioStation get currentStation {
    if (playlist.isEmpty) return kLatinStations.first;
    return playlist[stationIndex.clamp(0, playlist.length - 1)];
  }

  RadioPlayerState copyWith({
    RadioPlayerMode? mode,
    int? stationIndex,
    bool? isPlaying,
    Offset? position,
    List<LatinRadioStation>? playlist,
    List<api.RadioStation>? apiStations,
    bool clearApiStations = false,
  }) =>
      RadioPlayerState(
        mode: mode ?? this.mode,
        stationIndex: stationIndex ?? this.stationIndex,
        isPlaying: isPlaying ?? this.isPlaying,
        position: position ?? this.position,
        playlist: playlist ?? this.playlist,
        apiStations: clearApiStations ? null : (apiStations ?? this.apiStations),
      );
}

class RadioPlayerNotifier extends Notifier<RadioPlayerState> {
  RadioPlayerService get _player => ref.read(radioPlayerServiceProvider);

  @override
  RadioPlayerState build() => const RadioPlayerState();

  Future<void> play() async {
    state = state.copyWith(isPlaying: true);
    await _playCurrent();
  }

  Future<void> pause() async {
    await _player.pause();
    state = state.copyWith(isPlaying: false);
    ref.read(isPlayingProvider.notifier).set(false);
  }

  Future<void> toggle() async {
    if (state.isPlaying) {
      await pause();
      return;
    }

    try {
      await _player.resume();
      state = state.copyWith(isPlaying: true);
      ref.read(isPlayingProvider.notifier).set(true);
    } catch (_) {
      await _playCurrent();
    }
  }

  Future<void> nextStation() async {
    if (state.playlist.isEmpty) return;
    final next = (state.stationIndex + 1) % state.playlist.length;
    await _switchToIndex(next);
  }

  Future<void> prevStation() async {
    if (state.playlist.isEmpty) return;
    final prev =
        (state.stationIndex - 1 + state.playlist.length) % state.playlist.length;
    await _switchToIndex(prev);
  }

  Future<void> setStation(int index) async {
    if (index < 0 || index >= state.playlist.length) return;
    await _switchToIndex(index);
  }

  /// Plays an API station and shows the mini player.
  ///
  /// [contextStations] is the list the user was browsing (popular/search).
  /// Prev/next will cycle through that list so skips stay on working streams.
  Future<void> playApiStation(
    api.RadioStation station, {
    Size? screenSize,
    List<api.RadioStation>? contextStations,
  }) async {
    final playlist = _buildPlaylist(contextStations);
    final index = _indexOfApiStation(station, contextStations, playlist);

    final position = screenSize != null
        ? Offset(16, screenSize.height - 72.0 - 96.0 - 16)
        : state.position;

    state = state.copyWith(
      playlist: playlist,
      stationIndex: index,
      isPlaying: true,
      mode: RadioPlayerMode.expanded,
      position: position,
      apiStations: contextStations,
    );
    ref.read(currentStationProvider.notifier).set(station);

    await _playUrl(
      playlist[index].streamUrl,
      title: station.name,
      artist: station.country,
      artUri: station.logoUrl != null ? Uri.tryParse(station.logoUrl!) : null,
    );
  }

  void minimize() => state = state.copyWith(mode: RadioPlayerMode.minimized);

  void expand() => state = state.copyWith(mode: RadioPlayerMode.expanded);

  void hide() {
    state = state.copyWith(mode: RadioPlayerMode.hidden);
    _player.stop();
    ref.read(isPlayingProvider.notifier).set(false);
  }

  void updatePosition(Offset pos) => state = state.copyWith(position: pos);

  void snapToEdge(Size screenSize) {
    const fabSize = 52.0;
    final mid = screenSize.width / 2;
    final x = state.position.dx + fabSize / 2 < mid
        ? 10.0
        : screenSize.width - fabSize - 10.0;
    state = state.copyWith(position: Offset(x, state.position.dy));
  }

  Future<void> _switchToIndex(int index) async {
    state = state.copyWith(stationIndex: index, isPlaying: true);

    final apiList = state.apiStations;
    if (apiList != null && index < apiList.length) {
      ref.read(currentStationProvider.notifier).set(apiList[index]);
    }

    await _playCurrent();
  }

  Future<void> _playCurrent() {
    final s = state.currentStation;
    return _playUrl(
      s.streamUrl,
      title: s.name,
      artist: '${s.country} · ${s.genre}',
    );
  }

  Future<void> _playUrl(
    String streamUrl, {
    String? title,
    String? artist,
    Uri? artUri,
  }) async {
    try {
      await _player.play(
        streamUrl,
        title: title ?? 'Latin Territory Radio',
        artist: artist,
        artUri: artUri,
      );
      state = state.copyWith(isPlaying: true);
      ref.read(isPlayingProvider.notifier).set(true);
    } catch (e) {
      debugPrint('[RadioPlayer] Error reproduciendo stream: $e');
      state = state.copyWith(isPlaying: false);
      ref.read(isPlayingProvider.notifier).set(false);
    }
  }

  List<LatinRadioStation> _buildPlaylist(
    List<api.RadioStation>? contextStations,
  ) {
    if (contextStations != null && contextStations.isNotEmpty) {
      return contextStations.map(_fromApiStation).toList();
    }
    if (state.playlist.isNotEmpty) return state.playlist;
    return kLatinStations;
  }

  int _indexOfApiStation(
    api.RadioStation station,
    List<api.RadioStation>? contextStations,
    List<LatinRadioStation> playlist,
  ) {
    if (contextStations != null) {
      final i = contextStations.indexWhere((s) => s.id == station.id);
      if (i >= 0) return i;
    }
    final byUrl = playlist.indexWhere((s) => s.streamUrl == station.streamUrl);
    if (byUrl >= 0) return byUrl;
    return 0;
  }

  LatinRadioStation _fromApiStation(api.RadioStation station) {
    return LatinRadioStation(
      name: station.name,
      frequency: station.bitrate != null
          ? '${station.bitrate} kbps'
          : station.codec?.toUpperCase() ?? 'En vivo',
      country: _flagForCountryCode(station.countryCode) ??
          station.country ??
          '🌎',
      genre: station.tags.isNotEmpty ? station.tags.first : 'Radio',
      streamUrl: station.streamUrl,
    );
  }

  String? _flagForCountryCode(String? code) {
    const flags = {
      'CO': '🇨🇴',
      'MX': '🇲🇽',
      'AR': '🇦🇷',
      'ES': '🇪🇸',
      'AU': '🇦🇺',
      'CL': '🇨🇱',
      'PE': '🇵🇪',
      'VE': '🇻🇪',
      'EC': '🇪🇨',
      'BR': '🇧🇷',
    };
    return flags[code?.toUpperCase()];
  }
}

final radioPlayerProvider =
    NotifierProvider<RadioPlayerNotifier, RadioPlayerState>(
  RadioPlayerNotifier.new,
);
