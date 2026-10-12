import '../models/shop.dart';
import 'catalog.dart';

class ShopState {
  final List<BagItem> bag;
  final Set<String> saved;
  final List<DemoOrder> orders;
  final Address address;
  final bool coupon;
  ShopState({
    List<BagItem>? bag,
    Set<String>? saved,
    List<DemoOrder>? orders,
    this.address = const Address(),
    this.coupon = false,
  }) : bag = List.unmodifiable(bag ?? []),
       saved = Set.unmodifiable(saved ?? {}),
       orders = List.unmodifiable(orders ?? []);
  int get count => bag.fold(0, (sum, line) => sum + line.quantity);
  int get subtotal => bag.fold(
    0,
    (sum, line) => sum + productById(line.productId).price * line.quantity,
  );
  int get discount => coupon ? (subtotal * .1).round() : 0;
  int get total => subtotal - discount;
  ShopState copyWith({
    List<BagItem>? bag,
    Set<String>? saved,
    List<DemoOrder>? orders,
    Address? address,
    bool? coupon,
  }) => ShopState(
    bag: bag ?? this.bag,
    saved: saved ?? this.saved,
    orders: orders ?? this.orders,
    address: address ?? this.address,
    coupon: coupon ?? this.coupon,
  );
  ShopState add(Product product, String size) {
    if (!product.sizes.contains(size)) {
      throw ArgumentError('Choose an available size');
    }
    final key = '${product.id}|$size';
    final index = bag.indexWhere((e) => e.key == key);
    final next = [...bag];
    if (index < 0) {
      next.add(BagItem(product.id, size, 1));
    } else {
      if (next[index].quantity >= 10) throw StateError('Maximum 10 per size');
      next[index] = next[index].withQuantity(next[index].quantity + 1);
    }
    return copyWith(bag: next);
  }

  ShopState quantity(String key, int value) {
    if (value > 10) throw StateError('Maximum 10 per size');
    final next = bag
        .where((e) => e.key != key || value > 0)
        .map((e) => e.key == key ? e.withQuantity(value) : e)
        .toList();
    return copyWith(bag: next, coupon: next.isEmpty ? false : coupon);
  }

  ShopState toggleSaved(String id) {
    final next = {...saved};
    next.contains(id) ? next.remove(id) : next.add(id);
    return copyWith(saved: next);
  }

  ShopState applyCoupon(String code) {
    if (bag.isEmpty) throw StateError('Add something to your bag first');
    if (code.trim().toUpperCase() != 'KERA10') {
      throw ArgumentError('Use KERA10 for 10% off this demo order');
    }
    return copyWith(coupon: true);
  }

  ShopState complete(String method, {DateTime? now}) {
    if (bag.isEmpty) throw StateError('Your bag is empty');
    if (address.name.trim().isEmpty ||
        !RegExp(r'^\d{10}$').hasMatch(address.phone) ||
        address.street.trim().isEmpty ||
        address.city.trim().isEmpty ||
        !RegExp(r'^[1-9]\d{5}$').hasMatch(address.pin)) {
      throw StateError('Complete your delivery address');
    }
    if (!['UPI', 'Card', 'Cash on delivery'].contains(method)) {
      throw ArgumentError('Choose a payment method');
    }
    final stamp = now ?? DateTime.now();
    final order = DemoOrder(
      id: 'KK${stamp.microsecondsSinceEpoch}',
      date: stamp.toIso8601String(),
      method: method,
      items: List.of(bag),
      subtotal: subtotal,
      discount: discount,
      total: total,
      address: address,
    );
    return copyWith(bag: [], coupon: false, orders: [order, ...orders]);
  }

  Map<String, dynamic> toJson() => {
    'version': 1,
    'bag': bag.map((e) => e.toJson()).toList(),
    'saved': saved.toList(),
    'orders': orders.map((e) => e.toJson()).toList(),
    'address': address.toJson(),
    'coupon': coupon,
  };
  factory ShopState.fromJson(Map<String, dynamic> json) {
    final bag = <BagItem>[];
    for (final raw in json['bag'] as List? ?? []) {
      if (raw is! Map) continue;
      final matches = products.where((p) => p.id == raw['productId']);
      if (matches.isEmpty) continue;
      final p = matches.first;
      final size = raw['size'];
      final qty = raw['quantity'];
      if (size is! String ||
          !p.sizes.contains(size) ||
          qty is! int ||
          qty < 1) {
        continue;
      }
      final key = '${p.id}|$size';
      if (bag.any((e) => e.key == key)) continue;
      bag.add(BagItem(p.id, size, qty.clamp(1, 10)));
    }
    final saved = (json['saved'] as List? ?? [])
        .whereType<String>()
        .where((id) => products.any((p) => p.id == id))
        .toSet();
    final orders = <DemoOrder>[];
    for (final raw in json['orders'] as List? ?? []) {
      try {
        final order = DemoOrder.fromJson(Map<String, dynamic>.from(raw as Map));
        if (order.items.every(
          (e) => products.any((p) => p.id == e.productId),
        )) {
          orders.add(order);
        }
      } catch (_) {}
    }
    return ShopState(
      bag: bag,
      saved: saved,
      orders: orders,
      address: json['address'] is Map
          ? Address.fromJson(Map<String, dynamic>.from(json['address'] as Map))
          : const Address(),
      coupon: json['coupon'] == true && bag.isNotEmpty,
    );
  }
}
