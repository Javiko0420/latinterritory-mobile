/// Named route constants for the entire app.
///
/// Used with GoRouter for type-safe navigation.
class RouteNames {
  RouteNames._();

  // ── Auth ────────────────────────────────────────────────
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';

  // ── Main Tabs ───────────────────────────────────────────
  static const String home = 'home';
  static const String businesses = 'businesses';
  static const String businessDetail = 'business-detail';
  static const String jobs = 'jobs';
  static const String jobDetail = 'job-detail';
  static const String events = 'events';
  static const String eventDetail = 'event-detail';
  static const String forums = 'forums';
  static const String forumDetail = 'forum-detail';
  static const String forumPost = 'forum-post';
  static const String profile = 'profile';
  static const String editProfile = 'edit-profile';
  static const String changePassword = 'change-password';

  // ── Utilities ───────────────────────────────────────────
  static const String weather = 'weather';
  static const String sports = 'sports';
}
