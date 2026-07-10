import 'package:go_router/go_router.dart';
import 'package:swiss/features/auth/presentation/forgot_password_screen.dart';
import 'package:swiss/features/auth/presentation/login_and_registration_screen.dart';
import 'package:swiss/features/auth/presentation/reset_password_screen.dart';
import 'package:swiss/features/delivery/presentation/completed_delivery.dart';
import 'package:swiss/features/delivery/presentation/delivery_detail.dart';
import 'package:swiss/features/delivery/presentation/delivery_screen.dart';
import 'package:swiss/features/delivery/presentation/delivery_tracking_screen.dart';
import 'package:swiss/features/delivery/presentation/rate_rider.dart';
import 'package:swiss/features/delivery/presentation/view_detail_receipt.dart';
import 'package:swiss/features/home/presentations/confirm_request_screen.dart';
import 'package:swiss/features/home/presentations/homescreen.dart';
import 'package:swiss/features/home/presentations/mainshell.dart';
import 'package:swiss/features/home/presentations/request_service_screen.dart';
import 'package:swiss/features/home/presentations/rider_profile_screen.dart';
import 'package:swiss/features/home/presentations/view_summary_screen.dart';
import 'package:swiss/features/legal/presentation/privacy_policy.dart';
import 'package:swiss/features/legal/presentation/terms_of_service.dart';
import 'package:swiss/features/notifications/presentation/notification.dart';
import 'package:swiss/features/onboarding/presentations/first_splash_screen.dart';
import 'package:swiss/features/onboarding/presentations/second_splash_screen.dart';
import 'package:swiss/features/onboarding/presentations/third_splash_screen.dart';
import 'package:swiss/features/payments/presentations/account_details.dart';
import 'package:swiss/features/payments/presentations/payment_methods.dart';
import 'package:swiss/features/profile/presentations/profile_screen.dart';
import 'package:swiss/features/support/presentation/help_center.dart';
import 'package:swiss/features/support/presentation/live_chat.dart';

final appRouter = GoRouter(
  initialLocation: '/login_and_registration_screen',

  // redirect: (context, state) {
  //   final aboutToLogin = state.matchedLocation == '/login_and_registration_screen';
  //   return null;
  // },

  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          Mainshell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: "/dashboard", builder: (context, state) => Homescreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: "/delivery", builder: (context, state) => DeliveryScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: "/profile", builder: (context, state) => UserProfileScreen()),
          ],
        ),
      ],
    ),
    GoRoute(path: "/first_splash_screen", builder: (context, state) => SplashScreen(),),
    GoRoute(path: "/second_splash_screen", builder: (context, state) => SecondSplashScreen(),),
    GoRoute(path: "/third_splash_screen", builder: (context, state) => ThirdSplashScreen(),),
    GoRoute(path: "/login_and_registration_screen", builder: (context, state) => LoginAndRegistrationScreen(),),
    GoRoute(path: "/forgot_password_screen", builder: (context, state) => ForgotPasswordScreen(),),
    GoRoute(path: "/reset_password_screen", builder: (context, state) => ResetPasswordScreen(),),
    GoRoute(path: "/rider_profile_screen", builder: (context, state) => RiderProfileScreen(),),
    GoRoute(path: "/request_service_screen", builder: (context, state) => RequestServiceScreen(),),
    GoRoute(path: "/view_summary_screen", builder: (context, state) => ViewSummaryScreen(),),
    GoRoute(path: "/confirm_request_screen", builder: (context, state) => ConfirmRequestScreen(),),
    GoRoute(path: "/delivery_detail_screen", builder: (context, state) => DeliveryDetailsScreen(),),
    GoRoute(path: "/delivery_tracking_screen", builder: (context, state) => DeliveryTrackingScreen(),),
    GoRoute(path: "/view_detail_receipt_screen", builder: (context, state) => ViewDetailReceiptScreen(),),
    GoRoute(path: "/completed_delivery_screen", builder: (context, state) => CompletedDelivery(),),
    GoRoute(path: "/rate_rider_screen", builder: (context, state) => RateRiderScreen(),),
    GoRoute(path: "/acount_details_screen", builder: (context, state) => AccountDetailsScreen(),),
    GoRoute(path: "/payment_method_screen", builder: (context, state) => PaymentMethods(),),
    GoRoute(path: "/notification_screen", builder: (context, state) => NotificationScreen(),),
    GoRoute(path: "/privacy_policy_screen", builder: (context, state) => PrivacyPolicyScreen(),),
    GoRoute(path: "/terms_of_service_screen", builder: (context, state) => TermsOfService(),),
    GoRoute(path: "/help_center_screen", builder: (context, state) => HelpCenterScreen(),),
    GoRoute(path: "/live_chat_screen", builder: (context, state) => LiveChatScreen(),),

  ],
);
