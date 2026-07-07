import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_user/core/auth/auth_refresh_notifier.dart';
import 'package:wavego_user/core/routes/route_names.dart';
import 'package:wavego_user/repositories/user_repositories.dart';
import 'package:wavego_user/screens/ambulance/ambulance_screen.dart';
import 'package:wavego_user/screens/auth/create_profile_screen.dart';
import 'package:wavego_user/screens/auth/otp_verification_screen.dart';
import 'package:wavego_user/screens/auth/phone_login_screen.dart';
import 'package:wavego_user/screens/booking/booking_screens.dart';
import 'package:wavego_user/screens/bookings/booking_detail_screen.dart';
import 'package:wavego_user/screens/bookings/bookings_screen.dart';
import 'package:wavego_user/screens/home/home_screen.dart';
import 'package:wavego_user/screens/notifications/notification_detail_screen.dart';
import 'package:wavego_user/screens/notifications/notifications_screen.dart';
import 'package:wavego_user/screens/onboarding/onboarding_screen.dart';
import 'package:wavego_user/screens/rental/rental_flow_screens.dart';
import 'package:wavego_user/screens/profile/student_pass_screen.dart';
import 'package:wavego_user/screens/profile/subscription_screen.dart';
import 'package:wavego_user/screens/profile/profile_screen.dart';
import 'package:wavego_user/screens/profile/profile_sub_screens.dart';
import 'package:wavego_user/screens/profile/support_screens.dart';
import 'package:wavego_user/screens/shell/main_shell.dart';
import 'package:wavego_user/screens/splash/splash_screen.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/screens/wallet/wallet_screen.dart';
import 'package:wavego_user/screens/wallet/wallet_sub_screens.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorBookingsKey = GlobalKey<NavigatorState>(debugLabel: 'bookings');
final _shellNavigatorWalletKey = GlobalKey<NavigatorState>(debugLabel: 'wallet');
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final routerProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final authRefresh = ref.watch(authRefreshNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    refreshListenable: authRefresh,
    redirect: (context, state) async {
      final path = state.uri.path;

      if (path == RouteNames.splash) return null;

      const preAuthPaths = {
        RouteNames.onboarding,
        RouteNames.phoneLogin,
        RouteNames.otpVerification,
      };

      final loggedIn = await authRepo.isLoggedIn();

      if (!loggedIn) {
        if (preAuthPaths.contains(path)) return null;
        return RouteNames.phoneLogin;
      }

      if (path == RouteNames.phoneLogin || path == RouteNames.otpVerification) {
        final needsSetup = await authRepo.needsProfileSetup();
        return needsSetup ? RouteNames.createProfile : RouteNames.home;
      }

      if (path == RouteNames.createProfile) {
        final needsSetup = await authRepo.needsProfileSetup();
        return needsSetup ? null : RouteNames.home;
      }

      final needsSetup = await authRepo.needsProfileSetup();
      if (needsSetup) return RouteNames.createProfile;

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
        path: RouteNames.createProfile,
        builder: (_, __) => const CreateProfileScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorBookingsKey,
            routes: [
              GoRoute(
                path: RouteNames.bookings,
                builder: (_, __) => const BookingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorWalletKey,
            routes: [
              GoRoute(
                path: RouteNames.wallet,
                builder: (_, __) => const WalletScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: RouteNames.profile,
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.location,
        builder: (_, state) => LocationScreen(
          field: state.extra as String? ?? 'pickup',
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.book,
        builder: (_, __) => const BookRideScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.bookSearching,
        builder: (_, __) => const RideSearchingScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.bookTracking,
        builder: (_, __) => const RideTrackingScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.ambulance,
        builder: (_, __) => const AmbulanceScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.rental,
        builder: (_, __) => const RentalHoursScreen(),
        routes: [
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: 'vehicles',
            builder: (_, __) => const RentalVehiclesScreen(),
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: 'pickup',
            builder: (_, __) => const RentalPickupScreen(),
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: 'dropoff',
            builder: (_, __) => const RentalDropoffScreen(),
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: 'confirm',
            builder: (_, __) => const RentalConfirmScreen(),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/ambulance/tracking',
        builder: (_, __) => const AmbulanceTrackingScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.profileSettings,
        builder: (_, __) => const ProfileSettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.profileSavedPlaces,
        builder: (_, __) => const SavedPlacesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.profileHelp,
        builder: (_, __) => const UserSupportScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.profileAbout,
        builder: (_, __) => const AboutScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.profileSubscription,
        builder: (_, __) => const SubscriptionScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.profileStudentPass,
        builder: (_, __) => const StudentPassScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.walletBalance,
        builder: (_, __) => const WalletBalanceScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.walletBonus,
        builder: (_, __) => const WalletBonusScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.walletPaymentDetail,
        builder: (_, state) => PaymentMethodDetailScreen(
          method: state.extra! as PaymentMethod,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.walletAddPayment,
        builder: (_, __) => const AddPaymentMethodScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.walletAddPaymentSetup,
        builder: (_, state) => AddPaymentSetupScreen(
          methodType: state.extra as String? ?? 'upi',
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.walletAddPaymentSuccess,
        builder: (_, state) => AddPaymentSuccessScreen(
          methodType: state.extra as String? ?? 'upi',
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.profileEdit,
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.profilePhone,
        builder: (_, __) => const PhoneSettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.profileEmail,
        builder: (_, __) => const EmailSettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.profileEmergencyContact,
        builder: (_, __) => const EmergencyContactSettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.profileNotifications,
        builder: (_, __) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.profileHelpTopic,
        builder: (_, state) {
          final topic = state.extra! as (String, IconData, String);
          return HelpTopicScreen(title: topic.$1, icon: topic.$2, body: topic.$3);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.supportTickets,
        builder: (_, __) => const SupportTicketsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.supportCreateTicket,
        builder: (_, state) {
          final extra = state.extra! as (String, IconData);
          return CreateSupportTicketScreen(
            category: extra.$1,
            icon: extra.$2,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.supportTicketDetail,
        builder: (_, state) => SupportTicketDetailScreen(
          ticketId: state.extra! as String,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.bookingDetail,
        builder: (_, state) => BookingDetailScreen(
          item: state.extra! as ActivityItem,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.notificationDetail,
        builder: (_, state) => NotificationDetailScreen(
          notification: state.extra! as AppNotification,
        ),
      ),
    ],
  );
});
