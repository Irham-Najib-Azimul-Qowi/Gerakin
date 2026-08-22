import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/adaptive/presentation/pages/adaptive_debug_dashboard_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/validation/presentation/pages/ai_validation_dashboard_page.dart';
import '../../features/camera/presentation/pages/camera_page.dart';
import '../../features/community/presentation/pages/community_page.dart';
import '../../features/community/presentation/pages/create_post_page.dart';
import '../../features/community/presentation/pages/post_detail_page.dart';
import '../../features/community/models/community_post.dart';
import '../../features/exercise_library/models/full_exercise_definition.dart';
import '../../features/exercise_library/presentation/pages/exercise_detail_preview_page.dart';
import '../../features/exercise_library/presentation/pages/exercise_library_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/user/presentation/pages/profile_page.dart';
import '../../features/user/presentation/pages/edit_profile_page.dart';
import '../../features/user/presentation/pages/settings_page.dart';
import '../../features/user/presentation/pages/assessment_wizard_page.dart';
import '../../features/gamification/presentation/pages/gamification_dashboard_page.dart';
import '../../features/collaboration/presentation/pages/collaboration_hub_page.dart';
import '../../features/presentation/pages/ai_presentation_dashboard_page.dart';
import '../../features/settings/presentation/pages/component_gallery_page.dart';
import '../../features/workout/presentation/pages/workout_page.dart';
import '../../features/workout_session/presentation/exercise_detail_screen.dart';
import '../../features/workout_session/presentation/movement_preview_screen.dart';
import '../../features/workout_session/presentation/live_camera_screen.dart';
import '../../features/workout_session/presentation/session_summary_screen.dart';
import '../../features/workout_session/presentation/session_replay_screen.dart';
import '../../features/workout_session/models/workout_summary.dart';
import '../../features/exercise/domain/exercise_type.dart';
import '../../features/exercise/presentation/exercise_education_screen.dart';
import '../../features/exercise/presentation/exercise_screen.dart';
import '../../shared/widgets/main_shell.dart';
import 'route_names.dart';

/// Konfigurasi GoRouter untuk aplikasi GERAKIN.
///
/// Menggunakan [StatefulShellRoute] untuk mendukung Bottom Navigation
/// dengan state persistence di setiap tab.
class AppRouter {
  AppRouter._();

  /// GlobalKey untuk root navigator.
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Instance GoRouter.
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.auth,
    debugLogDiagnostics: true,
    routes: [
      // ── Shell Route (Bottom Navigation) ───────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0 – Beranda
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // Tab 1 – Latihan
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.workout,
                name: RouteNames.workout,
                builder: (context, state) => const WorkoutPage(),
              ),
            ],
          ),
          // Tab 2 – Komunitas
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.community,
                name: RouteNames.community,
                builder: (context, state) => const CommunityPage(),
              ),
            ],
          ),
          // Tab 3 – Profil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => const EditProfilePage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Routes di luar Shell (Full Screen) ────────────
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: RoutePaths.communityCreate,
        name: RouteNames.communityCreate,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreatePostPage(),
      ),
      GoRoute(
        path: RoutePaths.communityPostDetail,
        name: RouteNames.communityPostDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final post = state.extra as CommunityPost;
          return PostDetailPage(post: post);
        },
      ),
      GoRoute(
        path: RoutePaths.componentGallery,
        name: RouteNames.componentGallery,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ComponentGalleryPage(),
      ),
      // ── Auth Routes ────────────────────────────────────
      GoRoute(
        path: RoutePaths.auth,
        name: RouteNames.auth,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuthPage(),
        routes: [
          GoRoute(
            path: 'login',
            name: RouteNames.login,
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: 'register',
            name: RouteNames.register,
            builder: (context, state) => const RegisterPage(),
          ),
          GoRoute(
            path: 'forgot-password',
            name: RouteNames.forgotPassword,
            builder: (context, state) => const ForgotPasswordPage(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.camera,
        name: RouteNames.camera,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CameraPage(),
      ),
      GoRoute(
        path: RoutePaths.adaptiveDebug,
        name: RouteNames.adaptiveDebug,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdaptiveDebugDashboardPage(),
      ),
      GoRoute(
        path: RoutePaths.aiValidation,
        name: RouteNames.aiValidation,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AiValidationDashboardPage(),
      ),
      GoRoute(
        path: RoutePaths.exerciseLibrary,
        name: RouteNames.exerciseLibrary,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ExerciseLibraryPage(),
      ),
      GoRoute(
        path: RoutePaths.exerciseDetail,
        name: RouteNames.exerciseDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final exercise = state.extra as FullExerciseDefinition;
          return ExerciseDetailPreviewPage(exercise: exercise);
        },
      ),
      GoRoute(
        path: '/assessment-wizard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AssessmentWizardPage(),
      ),
      GoRoute(
        path: RoutePaths.gamification,
        name: RouteNames.gamification,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GamificationDashboardPage(),
      ),
      GoRoute(
        path: RoutePaths.collaboration,
        name: RouteNames.collaboration,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CollaborationHubPage(),
      ),
      GoRoute(
        path: RoutePaths.presentation,
        name: RouteNames.presentation,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AiPresentationDashboardPage(),
      ),
      GoRoute(
        path: RoutePaths.exerciseEducation,
        name: RouteNames.exerciseEducation,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final type = state.extra as ExerciseType? ?? ExerciseType.sideArmRaise;
          return ExerciseEducationScreen(exerciseType: type);
        },
      ),
      GoRoute(
        path: RoutePaths.interactiveExercise,
        name: RouteNames.interactiveExercise,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final type = state.extra as ExerciseType? ?? ExerciseType.sideArmRaise;
          return ExerciseScreen(exerciseType: type);
        },
      ),

      // ── Intelligent Rehabilitation Session Engine Routes ──────────
      GoRoute(
        path: '/workout-session/detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final exercise = state.extra as FullExerciseDefinition?;
          return ExerciseDetailScreen(exercise: exercise);
        },
      ),
      GoRoute(
        path: '/workout-session/preview',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final exercise = state.extra as FullExerciseDefinition;
          return MovementPreviewScreen(exercise: exercise);
        },
      ),
      GoRoute(
        path: '/workout-session/live',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final exercise = state.extra as FullExerciseDefinition;
          return LiveCameraScreen(exercise: exercise);
        },
      ),
      GoRoute(
        path: '/workout-session/summary',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final summary = state.extra as WorkoutSummary;
          return SessionSummaryScreen(summary: summary);
        },
      ),
      GoRoute(
        path: '/workout-session/replay',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final summary = state.extra as WorkoutSummary;
          return SessionReplayScreen(summary: summary);
        },
      ),
    ],
  );
}
