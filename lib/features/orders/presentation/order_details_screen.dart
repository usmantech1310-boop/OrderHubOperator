import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/order.dart';
import 'orders_controller.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  bool isLoading = false;

  Future<void> update(String status) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    await ref
        .read(ordersControllerProvider.notifier)
        .updateStatus(widget.order.id, status);

    await ref.read(ordersControllerProvider.notifier).fetchOrders();

    setState(() => isLoading = false);

    if (mounted) Navigator.pop(context);
  }

  Future<void> rejectWithReason() async {
    final reasonController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject Reason"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: "Enter reason"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            child: const Text("Submit", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await update("REJECTED");
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Customer: ${order.customerName}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: order.status == "NEW"
                    ? Colors.redAccent
                    : order.status == "CONFIRMED"
                    ? Colors.green
                    : Colors.blue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "Status: ${order.status}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (order.items.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Items",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...order.items.map(
                    (item) => Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text("${item['name']} x${item['quantity']}"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),

            if (order.modifiers.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Modifiers",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...order.modifiers.map(
                    (mod) => Card(
                      color: Colors.grey.shade200,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text("${mod['name']}"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),

            if (order.notes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Notes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Card(
                    color: Colors.yellow.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(order.notes),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),

            Card(
              color: Colors.grey.shade100,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Subtotal: \$${order.subtotal.toStringAsFixed(2)}"),
                    Text("Discount: \$${order.discount.toStringAsFixed(2)}"),
                    Text("Tip: \$${order.tip.toStringAsFixed(2)}"),
                    const Divider(),
                    Text(
                      "Total: \$${order.total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : () => update("CONFIRMED"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "Accept",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : rejectWithReason,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    "Reject",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () => update("READY"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text(
                    "Mark Ready",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
