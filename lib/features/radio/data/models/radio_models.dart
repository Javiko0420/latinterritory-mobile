import 'package:freezed_annotation/freezed_annotation.dart';

part 'radio_models.freezed.dart';
part 'radio_models.g.dart';

@freezed
abstract class RadioStation with _$RadioStation {
  const factory RadioStation({
    required String id,
    required String name,
    required String streamUrl,
    String? homepage,
    String? logoUrl,
    String? country,
    String? countryCode,
    String? language,
    String? codec,
    int? bitrate,
    @Default([]) List<String> tags,
    int? votes,
    int? clickCount,
  }) = _RadioStation;

  factory RadioStation.fromJson(Map<String, dynamic> json) =>
      _$RadioStationFromJson(json);
}
