import 'package:envied/envied.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

/// Type-safe environment variables.
///
/// Uses [envied] to read from .env files at build time and
/// obfuscate values in release builds.
///
/// Release builds use [.env.production]; debug/profile use [.env.development].
/// Run: `dart run build_runner build` after changing .env files.
@Envied(path: '.env.development', obfuscate: true, name: 'DevEnv')
abstract class DevEnv {
  @EnviedField(varName: 'BASE_URL')
  static String baseUrl = _DevEnv.baseUrl;

  @EnviedField(varName: 'GOOGLE_WEB_CLIENT_ID')
  static String googleWebClientId = _DevEnv.googleWebClientId;

  @EnviedField(varName: 'GOOGLE_IOS_CLIENT_ID')
  static String googleIosClientId = _DevEnv.googleIosClientId;
}

@Envied(path: '.env.production', obfuscate: true, name: 'ProdEnv')
abstract class ProdEnv {
  @EnviedField(varName: 'BASE_URL')
  static String baseUrl = _ProdEnv.baseUrl;

  @EnviedField(varName: 'GOOGLE_WEB_CLIENT_ID')
  static String googleWebClientId = _ProdEnv.googleWebClientId;

  @EnviedField(varName: 'GOOGLE_IOS_CLIENT_ID')
  static String googleIosClientId = _ProdEnv.googleIosClientId;
}

/// Active environment — production in release builds, development otherwise.
abstract class Env {
  static String get baseUrl =>
      kReleaseMode ? ProdEnv.baseUrl : DevEnv.baseUrl;

  static String get googleWebClientId =>
      kReleaseMode ? ProdEnv.googleWebClientId : DevEnv.googleWebClientId;

  static String get googleIosClientId =>
      kReleaseMode ? ProdEnv.googleIosClientId : DevEnv.googleIosClientId;
}
