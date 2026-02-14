import 'package:go_router/go_router.dart';
import 'package:orderhub_operator/features/orders/domain/order.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/orders/presentation/orders_list_screen.dart';
import '../features/orders/presentation/order_details_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrdersListScreen(),
    ),
    GoRoute(
      path: '/details',
      builder: (context, state) {
        final order = state.extra as Order;
        return OrderDetailsScreen(order: order);
      },
    ),
  ],
);
