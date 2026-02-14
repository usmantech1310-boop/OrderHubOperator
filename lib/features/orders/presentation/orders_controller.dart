import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:orderhub_operator/main.dart';
import '../data/orders_repository_impl.dart';
import '../domain/order.dart';
import 'package:hive_flutter/hive_flutter.dart';

final ordersRepositoryProvider = Provider((ref) => OrdersRepositoryImpl());

final ordersControllerProvider =
    StateNotifierProvider<OrdersController, AsyncValue<List<Order>>>(
      (ref) => OrdersController(ref.read(ordersRepositoryProvider)),
    );

class OrdersController extends StateNotifier<AsyncValue<List<Order>>> {
  final OrdersRepositoryImpl repository;
  Timer? _timer;
  final ordersBox = Hive.box('orders');

  OrdersController(this.repository) : super(const AsyncLoading()) {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final orders = await repository.fetchOrders();
      state = AsyncData(orders);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }

  Future<void> updateStatus(String id, String status) async {
    await repository.updateStatus(id, status);
    await fetchOrders();
  }

  // void _startAutoNewOrder() {
  //   _timer = Timer.periodic(const Duration(seconds: 20), (_) async {
  //     final newId = DateTime.now().millisecondsSinceEpoch.toString();

  //     final newOrder = Order(
  //       id: newId,
  //       customerName: "Customer $newId",
  //       total: 20.0 + (int.parse(newId) % 50),
  //       createdAt: DateTime.now(),
  //       status: "NEW",
  //       items: [],
  //       modifiers: [],
  //       subtotal: 20.0,
  //       discount: 0.0,
  //       tip: 0.0,
  //       notes: "",
  //     );

  //     await ordersBox.put(newId, newOrder.toMap());

  //     await showNewOrderNotification(newId);

  //     await fetchOrders();
  //   });
  // }
  void startPolling() {
    _timer ??= Timer.periodic(const Duration(seconds: 20), (_) async {
      final newId = DateTime.now().millisecondsSinceEpoch.toString();

      final newOrder = Order(
        id: newId,
        customerName: "Customer $newId",
        total: 20.0 + (int.parse(newId) % 50),
        createdAt: DateTime.now(),
        status: "NEW",
        items: [],
        modifiers: [],
        subtotal: 20.0,
        discount: 0.0,
        tip: 0.0,
        notes: "",
      );

      await ordersBox.put(newId, newOrder.toMap());

      await showNewOrderNotification(newId);

      await fetchOrders();
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> showNewOrderNotification(String orderId) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'orders_channel',
          'Orders',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: 'New Order Received',
      body: 'Order ID: $orderId',
      notificationDetails: details,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
