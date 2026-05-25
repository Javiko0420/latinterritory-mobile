/// Curated Latin radio stations for the floating mini player.
class LatinRadioStation {
  final String name;
  final String frequency;
  final String country;
  final String genre;
  final String streamUrl;

  const LatinRadioStation({
    required this.name,
    required this.frequency,
    required this.country,
    required this.genre,
    required this.streamUrl,
  });
}

/// Preset stations shown in the mini player station picker.
const List<LatinRadioStation> kLatinStations = [
  LatinRadioStation(
    name: 'Radioacktiva',
    frequency: '97.9 FM',
    country: '🇨🇴',
    genre: 'Rock Latino',
    streamUrl: 'https://playerservices.streamtheworld.com/api/livestream-redirect/RADIO_ACTIVA.mp3',
  ),
  LatinRadioStation(
    name: 'La Mega Bogotá',
    frequency: '90.9 FM',
    country: '🇨🇴',
    genre: 'Urban & Salsa',
    streamUrl: 'https://playerservices.streamtheworld.com/api/livestream-redirect/LA_MEGA_BOGOTA.mp3',
  ),
  LatinRadioStation(
    name: 'Los 40 México',
    frequency: '101.7 FM',
    country: '🇲🇽',
    genre: 'Pop Latino',
    streamUrl: 'https://playerservices.streamtheworld.com/api/livestream-redirect/LOS40_MX.mp3',
  ),
  LatinRadioStation(
    name: 'Oxigeno',
    frequency: '103.9 FM',
    country: '🇨🇴',
    genre: 'Electrónica',
    streamUrl: 'https://playerservices.streamtheworld.com/api/livestream-redirect/OXIGENO.mp3',
  ),
  LatinRadioStation(
    name: 'Radio Nacional',
    frequency: '96.1 FM',
    country: '🇦🇷',
    genre: 'Variado',
    streamUrl: 'http://streaming.radionacional.com.ar:8000/radionacional.mp3',
  ),
  LatinRadioStation(
    name: 'Cadena 100',
    frequency: '99.5 FM',
    country: '🇲🇽',
    genre: 'Pop',
    streamUrl: 'https://playerservices.streamtheworld.com/api/livestream-redirect/CAD100_MX.mp3',
  ),
];
