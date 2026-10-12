import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/shop_controller.dart';
import '../models/shop.dart';
import '../widgets/common.dart';
import 'bag.dart';
import 'checkout.dart';

class ProductPage extends StatefulWidget {
  final Product product;
  const ProductPage({super.key, required this.product});
  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late String size = widget.product.sizes.contains('M')
      ? 'M'
      : widget.product.sizes.first;
  void add({bool buy = false}) {
    final shop = ShopScope.of(context);
    try {
      shop.add(widget.product, size);
    } catch (e) {
      toast(context, 'Maximum 10 of this item per size.');
      return;
    }
    if (buy) {
      openPage(context, const CheckoutPage());
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('A lovely choice. Added to your bag.'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'View bag',
              onPressed: () => openPage(context, const BagPage()),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Copy product details',
            icon: const Icon(Icons.ios_share_outlined),
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(
                  text:
                      '${p.name} • ${money(p.price)}\nDiscover it on KeraBasket.',
                ),
              );
              if (context.mounted) toast(context, 'Product details copied.');
            },
          ),
          SaveButton(p),
          const BagButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: PageWidth(
        max: 720,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AspectRatio(
                aspectRatio: 1.05,
                child: ProductPhoto(p.photo, label: p.name, radius: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: emerald,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.6,
                    ),
                  ),
                  const SizedBox(height: 9),
                  PriceLabel(p, large: true),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: emerald, size: 17),
                      const SizedBox(width: 5),
                      Text(
                        '${p.rating}  (${p.reviews} sample reviews)',
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    p.id == 'kurta'
                        ? 'Color: Ivory'
                        : p.id == 'tote'
                        ? 'Color: Tan'
                        : 'Color: Warm ivory',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 33,
                    height: 33,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: emerald, width: 1.5),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.id == 'tote'
                            ? const Color(0xFFB98149)
                            : const Color(0xFFECE4D4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Size: $size',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: p.sizes
                        .map(
                          (s) => ChoiceChip(
                            label: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: Text(s),
                            ),
                            showCheckmark: false,
                            selectedColor: emerald,
                            labelStyle: TextStyle(
                              color: size == s ? Colors.white : ink,
                            ),
                            selected: size == s,
                            onSelected: (_) => setState(() => size = s),
                          ),
                        )
                        .toList(),
                  ),
                  const Divider(),
                  Text(
                    p.description,
                    style: const TextStyle(
                      color: muted,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    p.material,
                    style: const TextStyle(
                      fontSize: 12,
                      color: muted,
                      height: 1.6,
                    ),
                  ),
                  const Divider(),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.local_shipping_outlined,
                      color: emerald,
                    ),
                    title: Text(
                      'Free Delivery',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Delivery timing will be shown for live orders.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.verified_outlined, color: emerald),
                    title: Text('Thoughtfully selected'),
                    subtitle: Text(
                      'Sample catalog • Demo shopping experience',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomPanel(
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                'Add To Bag',
                outline: true,
                onPressed: () => add(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton('Buy now', onPressed: () => add(buy: true)),
            ),
          ],
        ),
      ),
    );
  }
}
