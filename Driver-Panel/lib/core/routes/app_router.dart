import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/screens/auth/otp_verification_screen.dart';
import 'package:wavego_driver/screens/auth/phone_login_screen.dart';
import 'package:wavego_driver/screens/dashboard/dashboard_screen.dart';
import 'package:wavego_driver/screens/documents/documents_screen.dart';
import 'package:wavego_driver/screens/notifications/notifications_screen.dart';
import 'package:wavego_driver/screens/onboarding/onboarding_screen.dart';
import 'package:wavego_driver/screens/profile/edit_profile_screen.dart';
import 'package:wavego_driver/screens/profile/profile_screen.dart';
import 'package:wavego_driver/screens/profile/ride_statistics_screen.dart';
import 'package:wavego_driver/screens/registration/registration_screen.dart';
import 'package:wavego_driver/screens/ride/active_trip_screen.dart';
import 'package:wavego_driver/screens/ride/payment_screen.dart';
import 'package:wavego_driver/screens/ride/ride_request_screen.dart';
import 'package:wavego_driver/screens/ride/ride_summary_screen.dart';
import 'package:wavego_driver/screens/settings/settings_screen.dart';
import 'package:wavego_driver/screens/sos/sos_screen.dart';
import 'package:wavego_driver/screens/splash/splash_screen.dart';
import 'package:wavego_driver/screens/support/support_screen.dart';
import 'package:wavego_driver/screens/trip/trip_detail_screen.dart';
import 'package:wavego_driver/screens/trip/trip_history_screen.dart';
import 'package:wavego_driver/screens/verification/verification_pending_screen.dart';
import 'package:wavego_driver/screens/wallet/wallet_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.phoneLogin,
        builder: (_, __) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: RouteNames.otpVerification,
        builder: (_, __) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: RouteNames.registration,
        builder: (_, __) => const RegistrationScreen(),
      ),
      GoRoute(
        path: RouteNames.verificationPending,
        builder: (_, __) => const VerificationPendingScreen(),
      ),
      GoRoute(
        path: RouteNames.dashboard,
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.rideRequest,
        pageBuilder: (_, __) => CustomTransitionPage(
          child: const RideRequestScreen(),
          transitionsBuilder: (_, animation, __, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.activeTrip,
        builder: (_, __) => const ActiveTripScreen(),
      ),
      GoRoute(
        path: RouteNames.payment,
        builder: (_, state) => PaymentScreen(
          payment: state.extra! as PaymentBreakdown,
        ),
      ),
      GoRoute(
        path: RouteNames.rideSummary,
        builder: (_, __) => const RideSummaryScreen(),
      ),
      GoRoute(
        path: RouteNames.trips,
        builder: (_, __) => const TripHistoryScreen(),
      ),
      GoRoute(
        path: '/trips/:id',
        builder: (_, state) => TripDetailScreen(
          tripId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: RouteNames.earnings,
        builder: (_, __) => const EarningsScreen(),
      ),
      GoRoute(
        path: RouteNames.wallet,
        builder: (_, __) => const WalletScreen(),
      ),
      GoRoute(
        path: RouteNames.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.editProfile,
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.rideStatistics,
        builder: (_, __) => const RideStatisticsScreen(),
      ),
      GoRoute(
        path: RouteNames.documents,
        builder: (_, __) => const DocumentsScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.support,
        builder: (_, __) => const SupportScreen(),
      ),
      GoRoute(
        path: RouteNames.sos,
        builder: (_, __) => const SosScreen(),
      ),
    ],
  );
});
