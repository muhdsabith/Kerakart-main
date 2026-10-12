import 'dart:convert';
import 'dart:io';
import 'package:kerakart/data/catalog.dart';
import 'package:kerakart/data/shop_state.dart';
import 'package:kerakart/models/shop.dart';

void check(bool condition, String label) {
  if (!condition) throw StateError('FAIL: $label');
}

void rejects(void Function() action, String label) {
  var failed = false;
  try {
    action();
  } catch (_) {
    failed = true;
  }
  check(failed, label);
}

void main() {
  var s = ShopState();
  check(s.total == 0 && s.count == 0, 'empty bag');
  rejects(() => s.complete('UPI'), 'empty checkout blocked');
  s = s.add(products[0], 'M').add(products[1], 'One size');
  check(s.subtotal == 1398 && s.count == 2, 'correct sample total');
  s = s.add(products[0], 'L').add(products[0], 'M');
  check(s.bag.length == 3 && s.count == 4, 'size variants stay separate');
  s = s.quantity('kurta|M', 1).quantity('kurta|L', 0);
  check(s.count == 2 && s.subtotal == 1398, 'quantity and removal');
  rejects(() => s.add(products[0], 'XXXL'), 'invalid size');
  rejects(() => s.quantity('kurta|M', 11), 'quantity cap');
  rejects(() => s.applyCoupon('fake'), 'invalid coupon');
  s = s.applyCoupon(' kera10 ');
  check(s.discount == 140 && s.total == 1258, 'coupon rounding');
  s = s.toggleSaved('kurta');
  check(s.saved.contains('kurta'), 'saved items');
  final restored = ShopState.fromJson(
    jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>,
  );
  check(
    restored.total == 1258 && restored.saved.contains('kurta'),
    'persistence round trip',
  );
  rejects(() => s.complete('UPI'), 'missing address blocked');
  s = s.copyWith(
    address: const Address(
      name: 'Demo Customer',
      phone: '9000000000',
      street: 'Sample house',
      city: 'Malappuram',
      pin: '676505',
    ),
  );
  rejects(() => s.complete('Unknown'), 'invalid payment choice blocked');
  final done = s.complete('UPI', now: DateTime(2026, 10, 4));
  check(
    done.count == 0 && !done.coupon && done.orders.length == 1,
    'checkout clears bag and coupon',
  );
  check(
    done.orders.first.total == 1258 && done.orders.first.items.length == 2,
    'immutable order snapshot',
  );
  final again = ShopState.fromJson(
    jsonDecode(jsonEncode(done.toJson())) as Map<String, dynamic>,
  );
  check(
    again.orders.first.address.name == 'Demo Customer' &&
        again.orders.first.total == 1258,
    'order restoration',
  );
  final malformed = ShopState.fromJson({
    'bag': [
      {'productId': 'gone', 'size': 'M', 'quantity': 1},
      {'productId': 'kurta', 'size': 'M', 'quantity': 99},
    ],
    'saved': ['gone', 'kurta'],
  });
  check(
    malformed.count == 10 && malformed.saved.length == 1,
    'stale catalog and quantities handled',
  );
  check(
    money(1398) == '₹1,398' && money(1234567) == '₹12,34,567',
    'Indian currency grouping',
  );
  stdout.writeln('PASS: shopping-state checks');
}
