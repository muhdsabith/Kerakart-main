import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../data/shop_controller.dart';
import '../models/shop.dart';
import '../widgets/common.dart';
import 'checkout.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = ShopScope.of(context).state;
    return PageWidth(
      max: 720,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Image.asset(
            'assets/images/kerabasket_logo.png',
            height: 170,
            color: emerald,
            colorBlendMode: BlendMode.srcIn,
            semanticLabel: 'KeraBasket logo',
          ),
          const SizedBox(height: 16),
          const Text(
            'Your Little Corner',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -.7,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFEAF2EC),
                child: Text(
                  state.address.name.isEmpty
                      ? 'K'
                      : state.address.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 26,
                    color: emerald,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.address.name.isEmpty
                          ? 'Hello, Lovely.'
                          : 'Hello, ${state.address.name.split(' ').first}.',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Make The Everyday Yours.',
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const StorageNotice(),
          tile(
            Icons.inventory_2_outlined,
            'My Orders',
            '${state.orders.length} demo orders',
            () => openPage(context, const OrdersPage()),
          ),
          tile(
            Icons.location_on_outlined,
            'Delivery Address',
            state.address.name.isEmpty
                ? 'Add Your Address'
                : state.address.summary,
            () => openPage(context, AddressEditor(initial: state.address)),
          ),
          tile(
            Icons.help_outline,
            'About This App',
            'How the KeraBasket demo works',
            () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Welcome to KeraBasket'),
                content: const SingleChildScrollView(
                  child: Text(
                    'Browse a curated sample catalog, save favourites and try checkout. Your bag, address and demo orders stay on this device.\n\nThe product photos and reviews are illustrative. Payments, shipping and online accounts are not connected.\n\nCoupon: KERA10 gives 10% off demo orders.\n\nVersion 1.0.0',
                    style: TextStyle(height: 1.6),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Got it'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36),
          const Icon(Icons.spa_outlined, color: emerald, size: 30),
          const SizedBox(height: 13),
          const Text(
            'KeraBasket',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              letterSpacing: -.8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Everyday, elevated.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 8),
          const Text(
            'Demo app • 1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: muted),
          ),
        ],
      ),
    );
  }

  Widget tile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, color: emerald),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: muted),
        ),
        trailing: const Icon(Icons.chevron_right, size: 19),
      ),
    ),
  );
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  @override
  Widget build(BuildContext context) {
    final orders = ShopScope.of(context).state.orders;
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: orders.isEmpty
          ? const EmptyView(
              icon: Icons.inventory_2_outlined,
              title: 'Your story starts here',
              subtitle: 'Your demo orders will appear here after checkout.',
            )
          : PageWidth(
              max: 720,
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final date = DateTime.tryParse(order.date)?.toLocal();
                  return Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: emerald,
                              size: 19,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Demo order saved',
                                style: TextStyle(
                                  color: emerald,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (date != null)
                              Text(
                                '${date.day}/${date.month}/${date.year}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: muted,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          order.id,
                          style: const TextStyle(color: muted, fontSize: 11),
                        ),
                        const SizedBox(height: 18),
                        ...order.items.map((item) {
                          final p = productById(item.productId);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 13),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 52,
                                  height: 60,
                                  child: ProductPhoto(
                                    p.photo,
                                    label: p.name,
                                    radius: 8,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.size} • Qty ${item.quantity}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(),
                        SummaryRow(
                          'Order total',
                          money(order.total),
                          strong: true,
                        ),
                        Text(
                          'Payment choice: ${order.method}',
                          style: const TextStyle(fontSize: 12, color: muted),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Deliver to ${order.address.name}\n${order.address.summary}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: muted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Preview only. No payment or shipment.',
                          style: TextStyle(fontSize: 11, color: emerald),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
