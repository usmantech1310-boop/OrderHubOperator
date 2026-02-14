import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:orderhub_operator/features/orders/domain/order.dart';
import 'package:orderhub_operator/features/orders/domain/orders_repository.dart';
import 'mock_orders_remote.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final remote = MockOrdersRemote();
  final ordersBox = Hive.box('orders');
  final pendingBox = Hive.box('pending_actions');

  @override
  Future<List<Order>> fetchOrders() async {
    final results = await Connectivity().checkConnectivity();
    bool isOnline = results.any((r) => r != ConnectivityResult.none);

    if (isOnline) {
      await syncPendingActions();
    }

    final localOrders = _getLocalOrders();

    if (isOnline) {
      final remoteOrders = await remote.fetchOrders();

      for (var remoteOrder in remoteOrders) {
        if (!localOrders.any((o) => o.id == remoteOrder.id)) {
          await ordersBox.put(remoteOrder.id, {
            "id": remoteOrder.id,
            "customerName": remoteOrder.customerName,
            "total": remoteOrder.total,
            "createdAt": remoteOrder.createdAt.toIso8601String(),
            "status": remoteOrder.status,
          });
        }
      }
    }

    return _getLocalOrders();
  }

  @override
  Future<void> updateStatus(String id, String status) async {
    final results = await Connectivity().checkConnectivity();
    bool isOnline = results.any((r) => r != ConnectivityResult.none);

    final existing = ordersBox.get(id);

    if (!isOnline) {
      await pendingBox.add({"id": id, "status": status});

      if (existing != null) {
        existing["status"] = status;
        await ordersBox.put(id, existing);
      }

      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (existing != null) {
      existing["status"] = status;
      await ordersBox.put(id, existing);
    }
  }

  Future<void> syncPendingActions() async {
    final results = await Connectivity().checkConnectivity();
    bool isOnline = results.any((r) => r != ConnectivityResult.none);

    if (!isOnline) return;

    final pendingActions = pendingBox.values.toList();

    for (var action in pendingActions) {
      final id = action["id"];
      final status = action["status"];

      await Future.delayed(const Duration(milliseconds: 500));

      final existing = ordersBox.get(id);
      if (existing != null) {
        existing["status"] = status;
        await ordersBox.put(id, existing);
      }
    }

    await pendingBox.clear();
  }

  List<Order> _getLocalOrders() {
    return ordersBox.values.map((e) {
      return Order(
        id: e["id"],
        customerName: e["customerName"],
        total: e["total"],
        createdAt: DateTime.parse(e["createdAt"]),
        status: e["status"],
      );
    }).toList();
  }
}
