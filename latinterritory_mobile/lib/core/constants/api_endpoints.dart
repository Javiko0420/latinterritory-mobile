/// All API route constants.
///
/// Mirrors the backend routes from the web repo.
/// Grouped by feature for easy navigation.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth (Mobile-specific) ──────────────────────────────
  static const String mobileLogin = '/api/auth/mobile/login';
  static const String mobileRefresh = '/api/auth/mobile/refresh';
  static const String mobileGoogle = '/api/auth/mobile/google';

  // ── Auth (Shared with web) ──────────────────────────────
  static const String register = '/api/auth/register';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';

  // ── Users ───────────────────────────────────────────────
  static const String usersMe = '/api/users/me';
  static const String completeProfile = '/api/users/me/complete-profile';
  static const String changePassword = '/api/users/me/change-password';

  // ── Businesses ──────────────────────────────────────────
  static const String businesses = '/api/businesses';
  static String businessDetail(String id) => '/api/businesses/$id';

  // ── Jobs ────────────────────────────────────────────────
  static const String jobs = '/api/jobs';
  static String jobDetail(String id) => '/api/jobs/$id';

  // ── Events ──────────────────────────────────────────────
  static const String events = '/api/events';
  static String eventDetail(String id) => '/api/events/$id';

  // ── Forums ──────────────────────────────────────────────
  static const String forums = '/api/forums';
  static String forumDetail(String id) => '/api/forums/$id';
  static String forumPosts(String id) => '/api/forums/$id/posts';
  static String postComments(String id) => '/api/posts/$id/comments';
  static String postLike(String id) => '/api/posts/$id/like';
  static String postReport(String id) => '/api/posts/$id/report';
  static String commentLike(String id) => '/api/comments/$id/like';
  static String commentReport(String id) => '/api/comments/$id/report';

  // ── Utilities ───────────────────────────────────────────
  static const String weather = '/api/weather';
  static const String exchangeRates = '/api/tasas';
  static const String translate = '/api/translate';
  static const String i18nMessages = '/api/i18n/messages';
  static const String foundersCount = '/api/founders/count';

  // ── Sports ──────────────────────────────────────────────
  static const String sportsTeams = '/api/sports/teams';
  static const String sportsLeague = '/api/sports/league';
  static const String sportsFixtures = '/api/sports/fixtures';
  static const String sportsSummary = '/api/sports/summary';
}
