import 'package:go_router/go_router.dart';
import '../../presentation/screens/new_credit/client_update_screen.dart';
import '../../presentation/screens/new_credit/new_credit_financial_screen.dart';
import '../../presentation/screens/new_credit/new_credit_store_screen.dart';
import '../../presentation/screens/new_credit_request_screen.dart';
import '../../presentation/screens/notifications_screen.dart';
import '../../presentation/screens/screens.dart'; // Crearemos este archivo barril abajo
import '../../presentation/screens/client_data_screen.dart';
import '../../presentation/screens/store_data_screen.dart';
import '../../presentation/screens/credit_data_screen.dart';
import '../../presentation/screens/forgot_password_screen.dart';
import '../../presentation/screens/reset_password_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/client_data_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/client-data',
      builder: (context, state) => const ClientDataScreen(),
    ),
    GoRoute(
      path: '/store-data',
      builder: (context, state) => const StoreDataScreen(),
    ),
    GoRoute(
      path: '/credit-data',
      builder: (context, state) => const CreditDataScreen(),
    ),
    GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen()
    ),
    GoRoute(
        path: '/reset-password',
        builder: (_, __) => const ResetPasswordScreen()
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
//    GoRoute(
//      path: '/new-credit-request',
//      builder: (context, state) {
//        final clienteId = state.extra as int;
//        return NewCreditRequestScreen(clienteId: clienteId);
//      },
//    ),
    GoRoute(
      path: '/new-credit-request', // Mantenemos el path que usabas en home
      builder: (context, state) {
        //  final clienteId = state.extra as int;
        //return ClientUpdateScreen(clienteId: clienteId);
        return const ClientUpdateScreen();

      },
    ),
    GoRoute(
      path: '/new-credit-store',
      builder: (context, state) {
        //final clienteId = state.extra as int;
        return NewCreditStoreScreen();
      },
    ),
    GoRoute(
      path: '/new-credit-financial',
      builder: (context, state) {
        final tiendaId = state.extra as int;
        //final Map<String, int> args = state.extra as Map<String, int>;
        return NewCreditFinancialScreen(
          // clienteId: args['clienteId']!,
          // tiendaId: args['tiendaId']!,
            tiendaId: tiendaId
        );
      },
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) {
        // Recibimos el email que enviamos desde la pantalla anterior
        final email = state.extra as String? ?? 'tu correo';
        return VerifyOtpScreen(email: email);
      },
    ),
  ],
);