import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/auth/ui/login_screen.dart';
import 'package:latinterritory/features/auth/ui/register_screen.dart';
import 'package:latinterritory/features/auth/ui/forgot_password_screen.dart';
import 'package:latinterritory/features/home/ui/home_screen.dart';
import 'package:latinterritory/features/businesses/ui/business_detail_screen.dart';
import 'package:latinterritory/features/businesses/ui/business_list_screen.dart';
import 'package:latinterritory/features/businesses/ui/create_business_screen.dart';
import 'package:latinterritory/features/jobs/ui/job_detail_screen.dart';
import 'package:latinterritory/features/jobs/ui/job_list_screen.dart';
import 'package:latinterritory/features/jobs/ui/create_job_screen.dart';
import 'package:latinterritory/features/events/ui/event_detail_screen.dart';
import 'package:latinterritory/features/events/ui/event_list_screen.dart';
import 'package:latinterritory/features/events/ui/create_event_screen.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';
import 'package:latinterritory/features/forums/ui/forum_list_screen.dart';
import 'package:latinterritory/features/forums/ui/forum_posts_screen.dart';
import 'package:latinterritory/features/forums/ui/post_comments_screen.dart';
import 'package:latinterritory/features/profile/ui/profile_screen.dart';
import 'package:latinterritory/features/profile/ui/edit_profile_screen.dart';
import 'package:latinterritory/features/profile/ui/change_password_screen.dart';
import 'package:latinterritory/features/profile/ui/my_publications_screen.dart';
import 'package:latinterritory/features/businesses/ui/edit_business_screen.dart';
import 'package:latinterritory/features/events/ui/edit_event_screen.dart';
import 'package:latinterritory/features/jobs/ui/edit_job_screen.dart';
import 'package:latinterritory/features/exchange/ui/exchange_screen.dart';
import 'package:latinterritory/features/sports/ui/sports_screen.dart';
import 'package:latinterritory/features/radio/ui/radio_screen.dart';
import 'package:latinterritory/features/weather/ui/weather_screen.dart';
import 'package:latinterritory/shared/widgets/lt_main_scaffold.dart';

/// Global navigator keys — defined once, never recreated.
final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

// ── Router Refresh Notifier ───────────────────────────────
//
// Bridges Riverpod auth state → GoRouter redirect refreshes.
//
// The GoRouter instance is created ONLY ONCE per app lifetime.
// This ChangeNotifier fires whenever auth state changes, telling
// GoRouter to re-run its redirect function — without recreating
// the router or its GlobalKeys (which caused "Multiple GlobalKey" errors).

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen<AsyncValue<AuthState>>(
      authStateProvider,
      (_, _) => notifyListeners(),
    );
  }
}

// ── Router Provider ───────────────────────────────────────

/// GoRouter configuration provider.
///
/// The router is created **once** and never recreated.
/// Auth changes are handled via [refreshListenable] + redirect.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,

    // ── Auth Redirect Guard ─────────────────────────────
    redirect: (context, state) {
      // Read (don't watch) — the refreshListenable handles re-runs.
      final authState = ref.read(authStateProvider);

      // Skip redirect while auth is still resolving.
      if (!authState.hasValue) return null;

      final isLoggedIn = authState.value!.isAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      // Not logged in → protect private routes.
      if (!isLoggedIn && !isAuthRoute) {
        const publicPaths = [
          '/home',
          '/businesses',
          '/jobs',
          '/events',
          '/weather',
          '/exchange',
          '/sports',
          '/radio',
        ];
        final isPublic = publicPaths.any(
          (p) => state.matchedLocation.startsWith(p),
        );
        if (!isPublic) return '/auth/login';
      }

      // Already logged in and on auth page → home.
      if (isLoggedIn && isAuthRoute) return '/home';

      return null;
    },

    routes: [
      // ── Auth Routes (no bottom nav) ───────────────────
      GoRoute(
        path: '/auth/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ── Publish Routes (full-screen, outside shell) ──────
      GoRoute(
        path: '/businesses/create',
        name: RouteNames.createBusiness,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CreateBusinessScreen(),
      ),
      GoRoute(
        path: '/events/create',
        name: RouteNames.createEvent,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CreateEventScreen(),
      ),
      GoRoute(
        path: '/jobs/create',
        name: RouteNames.createJob,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CreateJobScreen(),
      ),

      // ── Profile Sub-routes (full-screen, outside shell) ─
      GoRoute(
        path: '/profile/edit',
        name: RouteNames.editProfile,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/change-password',
        name: RouteNames.changePassword,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/profile/my-publications',
        name: RouteNames.myPublications,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MyPublicationsScreen(),
      ),

      // ── Edit Routes (full-screen, outside shell) ──────
      GoRoute(
        path: '/businesses/edit/:slug',
        name: RouteNames.editBusiness,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => EditBusinessScreen(
          businessSlug: state.pathParameters['slug']!,
        ),
      ),
      GoRoute(
        path: '/events/edit/:id',
        name: RouteNames.editEvent,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => EditEventScreen(
          eventId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/jobs/edit/:id',
        name: RouteNames.editJob,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => EditJobScreen(
          jobId: state.pathParameters['id']!,
        ),
      ),

      // ── Detail Routes (full-screen, outside shell) ───
      GoRoute(
        path: '/events/:id',
        name: RouteNames.eventDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => EventDetailScreen(
          eventId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/jobs/:id',
        name: RouteNames.jobDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => JobDetailScreen(
          jobId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/businesses/:slug',
        name: RouteNames.businessDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BusinessDetailScreen(
          slug: state.pathParameters['slug']!,
        ),
      ),
      GoRoute(
        path: '/forums/:id',
        name: RouteNames.forumDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            ForumPostsScreen(forum: state.extra as Forum),
      ),
      GoRoute(
        path: '/forums/:forumId/posts/:postId',
        name: RouteNames.forumPost,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => PostCommentsScreen(
          post: state.extra as ForumPost,
          forumId: state.pathParameters['forumId']!,
        ),
      ),

      // ── Main App (with bottom nav) ────────────────────
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return LtMainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: RouteNames.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/businesses',
            name: RouteNames.businesses,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BusinessListScreen(),
            ),
          ),
          GoRoute(
            path: '/jobs',
            name: RouteNames.jobs,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: JobListScreen(),
            ),
          ),
          GoRoute(
            path: '/events',
            name: RouteNames.events,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EventListScreen(),
            ),
          ),
          GoRoute(
            path: '/forums',
            name: RouteNames.forums,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ForumListScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: RouteNames.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/weather',
            name: RouteNames.weather,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WeatherScreen(),
            ),
          ),
          GoRoute(
            path: '/exchange',
            name: RouteNames.exchange,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ExchangeScreen(),
            ),
          ),
          GoRoute(
            path: '/sports',
            name: RouteNames.sports,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SportsScreen(),
            ),
          ),
          GoRoute(
            path: '/radio',
            name: RouteNames.radio,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RadioScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
