import 'package:envied/envied.dart';

part 'env.g.dart';

/// Type-safe environment variables.
///
/// Uses [envied] to read from .env files at build time and
/// obfuscate values in release builds.
///
/// Run: `dart run build_runner build` after changing .env files.
@Envied(path: '.env.development', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'BASE_URL')
  static String baseUrl = _Env.baseUrl;

  @EnviedField(varName: 'GOOGLE_WEB_CLIENT_ID')
  static String googleWebClientId = _Env.googleWebClientId;

  @EnviedField(varName: 'GOOGLE_IOS_CLIENT_ID')
  static String googleIosClientId = _Env.googleIosClientId;
}
