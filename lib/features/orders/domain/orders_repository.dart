import 'order.dart';

abstract class OrdersRepository {
  Future<List<Order>> fetchOrders();
  Future<void> updateStatus(String id, String status);
}
