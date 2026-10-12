import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../data/shop_controller.dart';
import '../models/shop.dart';
import '../widgets/common.dart';
import 'checkout.dart';
import 'product.dart';

class BagPage extends StatelessWidget {
  const BagPage({super.key});
  Future<void> coupon(BuildContext context) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('A little treat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Try KERA10 for 10% off your demo order.',
              style: TextStyle(color: muted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Coupon code'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (context.mounted && value != null) {
      try {
        ShopScope.of(context).coupon(value);
        toast(context, 'KERA10 applied. Enjoy 10% off.');
      } catch (_) {
        toast(context, 'That code is not available. Try KERA10.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = ShopScope.of(context);
    final state = shop.state;
    return Scaffold(
      appBar: AppBar(title: const Text('Your bag')),
      body: state.bag.isEmpty
          ? EmptyView(
              icon: Icons.shopping_bag_outlined,
              title: 'Room for something lovely',
              subtitle: 'Your bag is waiting for your everyday favourites.',
              action: 'Continue shopping',
              onAction: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            )
          : PageWidth(
              max: 720,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                children: [
                  Text(
                    '${state.count} ${state.count == 1 ? 'item' : 'items'}',
                    style: const TextStyle(color: muted),
                  ),
                  const SizedBox(height: 22),
                  const StorageNotice(),
                  ...state.bag.map((item) => BagTile(item)),
                  const SizedBox(height: 10),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      leading: const Icon(
                        Icons.local_offer_outlined,
                        color: emerald,
                      ),
                      title: Text(
                        state.coupon ? 'KERA10 applied' : 'Apply coupon',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: state.coupon
                          ? Text(
                              'You saved ${money(state.discount)}',
                              style: const TextStyle(
                                color: emerald,
                                fontSize: 12,
                              ),
                            )
                          : null,
                      trailing: state.coupon
                          ? IconButton(
                              tooltip: 'Remove coupon',
                              onPressed: shop.removeCoupon,
                              icon: const Icon(Icons.close, size: 18),
                            )
                          : const Icon(Icons.chevron_right),
                      onTap: state.coupon ? null : () => coupon(context),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Order summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  SummaryRow('Subtotal', money(state.subtotal)),
                  SummaryRow('Delivery', 'FREE', green: true),
                  if (state.coupon)
                    SummaryRow(
                      'KERA10 discount',
                      '−${money(state.discount)}',
                      green: true,
                    ),
                  const Divider(),
                  SummaryRow('Total', money(state.total), strong: true),
                  const SizedBox(height: 25),
                  const Center(
                    child: Text(
                      'Good choices. All in one place.',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: state.bag.isEmpty
          ? null
          : BottomPanel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryButton(
                    'Continue To Checkout',
                    onPressed: () => openPage(context, const CheckoutPage()),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Demo checkout • No real payment',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ),
    );
  }
}

class BagTile extends StatelessWidget {
  final BagItem item;
  const BagTile(this.item, {super.key});
  @override
  Widget build(BuildContext context) {
    final product = productById(item.productId);
    final shop = ShopScope.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => openPage(context, ProductPage(product: product)),
            child: SizedBox(
              width: 86,
              height: 118,
              child: ProductPhoto(
                product.photo,
                label: product.name,
                radius: 10,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => openPage(context, ProductPage(product: product)),
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${item.size}',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 9),
                Text(
                  money(product.price * item.quantity),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: line),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 38,
                            height: 40,
                            child: IconButton(
                              tooltip: item.quantity == 1
                                  ? 'Remove item'
                                  : 'Decrease quantity',
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () =>
                                  shop.quantity(item.key, item.quantity - 1),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                            child: Text(
                              '${item.quantity}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          SizedBox(
                            width: 38,
                            height: 40,
                            child: IconButton(
                              tooltip: 'Increase quantity',
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: item.quantity >= 10
                                  ? null
                                  : () => shop.quantity(
                                      item.key,
                                      item.quantity + 1,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove ${product.name}',
                      onPressed: () => shop.quantity(item.key, 0),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: muted,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
