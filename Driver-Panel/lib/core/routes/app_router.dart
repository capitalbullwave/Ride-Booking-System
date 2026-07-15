import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/models/payment_completion_data.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/models/wallet_model.dart';
import 'package:wavego_driver/providers/auth_session_provider.dart';
import 'package:wavego_driver/screens/auth/onboarding/kyc_upload_screen.dart';
import 'package:wavego_driver/screens/auth/onboarding/license_upload_screen.dart';
import 'package:wavego_driver/screens/auth/onboarding/photo_name_screen.dart';
import 'package:wavego_driver/screens/auth/onboarding/vehicle_documents_screen.dart';
import 'package:wavego_driver/screens/auth/onboarding/vehicle_number_screen.dart';
import 'package:wavego_driver/screens/auth/driving_license_question_screen.dart';
import 'package:wavego_driver/screens/auth/document_centre_screen.dart';
import 'package:wavego_driver/screens/auth/captain_vehicle_selection_screen.dart';
import 'package:wavego_driver/screens/auth/captain_city_selection_screen.dart';
import 'package:wavego_driver/screens/auth/captain_welcome_screen.dart';
import 'package:wavego_driver/screens/auth/otp_verification_screen.dart';
import 'package:wavego_driver/screens/auth/phone_login_screen.dart';
import 'package:wavego_driver/screens/dashboard/dashboard_screen.dart';
import 'package:wavego_driver/screens/documents/documents_screen.dart';
import 'package:wavego_driver/screens/notifications/notifications_screen.dart';
import 'package:wavego_driver/screens/onboarding/onboarding_screen.dart';
import 'package:wavego_driver/screens/profile/edit_profile_screen.dart';
import 'package:wavego_driver/screens/profile/emergency_contacts_screen.dart';
import 'package:wavego_driver/screens/profile/profile_screen.dart';
import 'package:wavego_driver/screens/profile/refer_earn_screen.dart';
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
import 'package:wavego_driver/screens/wallet/payment_method_screen.dart';
import 'package:wavego_driver/screens/wallet/wallet_screen.dart';

const _publicRoutes = <String>{
  RouteNames.splash,
  RouteNames.onboarding,
  RouteNames.phoneLogin,
  RouteNames.otpVerification,
};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authSessionProvider, (_, __) => refresh.value++);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    refreshListenable: refresh,
    redirect: (context, state) {
      final isAuthenticated = ref.read(authSessionProvider);
      final location = state.matchedLocation;

      if (!isAuthenticated && !_publicRoutes.contains(location)) {
        return RouteNames.phoneLogin;
      }

      if (isAuthenticated &&
          (location == RouteNames.phoneLogin ||
              location == RouteNames.otpVerification)) {
        return RouteNames.splash;
      }

      return null;
    },
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
        path: RouteNames.captainWelcome,
        builder: (_, __) => const CaptainWelcomeScreen(),
      ),
      GoRoute(
        path: RouteNames.captainCitySelection,
        builder: (_, __) => const CaptainCitySelectionScreen(),
      ),
      GoRoute(
        path: RouteNames.captainVehicleSelection,
        builder: (_, __) => const CaptainVehicleSelectionScreen(),
      ),
      GoRoute(
        path: RouteNames.documentCentre,
        builder: (_, __) => const DocumentCentreScreen(),
      ),
      GoRoute(
        path: RouteNames.drivingLicenseQuestion,
        builder: (_, __) => const DrivingLicenseQuestionScreen(),
      ),
      GoRoute(
        path: RouteNames.onboardingLicenseUpload,
        builder: (_, __) => const LicenseUploadScreen(),
      ),
      GoRoute(
        path: RouteNames.onboardingLicenseNumber,
        redirect: (_, __) => RouteNames.onboardingLicenseUpload,
      ),
      GoRoute(
        path: RouteNames.onboardingPhotoName,
        builder: (_, __) => const PhotoNameScreen(),
      ),
      GoRoute(
        path: RouteNames.onboardingVehicleNumber,
        builder: (_, __) => const VehicleNumberScreen(),
      ),
      GoRoute(
        path: RouteNames.onboardingKyc,
        builder: (_, __) => const KycUploadScreen(),
      ),
      GoRoute(
        path: RouteNames.onboardingVehicleDocuments,
        builder: (_, __) => const VehicleDocumentsScreen(),
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
          completion: state.extra as PaymentCompletionData?,
        ),
      ),
      GoRoute(
        path: RouteNames.rideSummary,
        builder: (_, state) => RideSummaryScreen(
          rideId: state.extra as String?,
        ),
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
        builder: (_, __) => const WalletScreen(initialTab: 0),
      ),
      GoRoute(
        path: RouteNames.wallet,
        builder: (_, __) => const WalletScreen(initialTab: 1),
      ),
      GoRoute(
        path: RouteNames.paymentMethod,
        builder: (_, state) => PaymentMethodScreen(
          existingBank: state.extra as BankInfo?,
        ),
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
        path: RouteNames.emergencyContacts,
        builder: (_, __) => const EmergencyContactsScreen(),
      ),
      GoRoute(
        path: RouteNames.rideStatistics,
        builder: (_, __) => const RideStatisticsScreen(),
      ),
      GoRoute(
        path: RouteNames.referEarn,
        builder: (_, __) => const ReferEarnScreen(),
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
        path: RouteNames.supportTicketDetail,
        builder: (_, state) => DriverSupportTicketDetailScreen(
          ticketId: state.extra! as String,
        ),
      ),
      GoRoute(
        path: RouteNames.sos,
        builder: (_, __) => const SosScreen(),
      ),
    ],
  );
});
