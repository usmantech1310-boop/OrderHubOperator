import 'package:orderhub_operator/features/orders/domain/order.dart';

class MockOrdersRemote {
  Future<List<Order>> fetchOrders() async {
    await Future.delayed(const Duration(seconds: 1));

    return List.generate(
      5,
      (index) => Order(
        id: "$index",
        customerName: "Customer $index",
        total: 20.0 + index,
        createdAt: DateTime.now(),
        status: "NEW",
      ),
    );
  }
}
