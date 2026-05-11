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
import 'package:latinterritory/features/jobs/ui/job_detail_screen.dart';
import 'package:latinterritory/features/jobs/ui/job_list_screen.dart';
import 'package:latinterritory/features/events/ui/event_detail_screen.dart';
import 'package:latinterritory/features/events/ui/event_list_screen.dart';
import 'package:latinterritory/features/forums/data/models/forum_models.dart';
import 'package:latinterritory/features/forums/ui/forum_list_screen.dart';
import 'package:latinterritory/features/forums/ui/forum_posts_screen.dart';
import 'package:latinterritory/features/forums/ui/post_comments_screen.dart';
import 'package:latinterritory/features/profile/ui/profile_screen.dart';
import 'package:latinterritory/features/weather/ui/weather_screen.dart';
import 'package:latinterritory/shared/widgets/lt_main_scaffold.dart';

/// Global navigator key for accessing navigation outside widget tree.
final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration provider.
///
/// Redirects unauthenticated users to login.
/// Uses ShellRoute for bottom navigation tabs.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: true,

    // ── Auth Redirect Guard ─────────────────────────────
    redirect: (context, state) {
      // Skip redirect while auth is still resolving (no value yet).
      // Prevents false logouts from transient AsyncLoading states.
      if (!authState.hasValue) return null;

      final isLoggedIn = authState.value!.isAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      // Not logged in and trying to access protected route → login.
      if (!isLoggedIn && !isAuthRoute) {
        // Allow public routes (home, businesses, jobs, events) without auth.
        final publicPaths = ['/home', '/businesses', '/jobs', '/events', '/weather'];
        final isPublic = publicPaths.any(
          (p) => state.matchedLocation.startsWith(p),
        );
        if (!isPublic) {
          return '/auth/login';
        }
      }

      // Already logged in and on auth page → home.
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

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
        ],
      ),
    ],
  );
});
