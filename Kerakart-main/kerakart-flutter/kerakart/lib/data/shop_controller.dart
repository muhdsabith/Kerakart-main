import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shop.dart';
import 'shop_state.dart';

class ShopController extends ChangeNotifier {
  final SharedPreferences? preferences;
  ShopState state;
  String? storageError;
  Future<void> _pending = Future.value();
  ShopController(this.preferences, this.state);
  static Future<ShopController> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final text = prefs.getString('kerakart_v1');
      try {
        return ShopController(
          prefs,
          text == null
              ? ShopState()
              : ShopState.fromJson(jsonDecode(text) as Map<String, dynamic>),
        );
      } catch (_) {
        return ShopController(prefs, ShopState())
          ..storageError =
              'Saved data could not be restored. A fresh demo has been opened.';
      }
    } catch (_) {
      return ShopController(null, ShopState())
        ..storageError =
            'Device storage is unavailable. Changes will last for this session only.';
    }
  }

  void _update(ShopState next) {
    state = next;
    notifyListeners();
    final encoded = jsonEncode(next.toJson());
    _pending = _pending.then((_) async {
      if (preferences == null) return;
      try {
        final ok = await preferences!.setString('kerakart_v1', encoded);
        if (!ok) throw StateError('Write failed');
        storageError = null;
      } catch (_) {
        storageError = 'Changes could not be saved on this device.';
      }
      notifyListeners();
    });
  }

  void add(Product p, String size) => _update(state.add(p, size));
  void quantity(String key, int value) => _update(state.quantity(key, value));
  void toggleSaved(String id) => _update(state.toggleSaved(id));
  void coupon(String code) => _update(state.applyCoupon(code));
  void removeCoupon() => _update(state.copyWith(coupon: false));
  void address(Address address) => _update(state.copyWith(address: address));
  Future<DemoOrder> placeDemoOrder(String method) async {
    await _pending;
    final next = state.complete(method);
    if (preferences == null) {
      throw StateError(
        'Device storage is unavailable. Please try again later.',
      );
    }
    final ok = await preferences!.setString(
      'kerakart_v1',
      jsonEncode(next.toJson()),
    );
    if (!ok) {
      throw StateError('Could not save this demo order. Please try again.');
    }
    state = next;
    storageError = null;
    notifyListeners();
    return next.orders.first;
  }
}

class ShopScope extends InheritedNotifier<ShopController> {
  const ShopScope({
    super.key,
    required ShopController controller,
    required super.child,
  }) : super(notifier: controller);
  static ShopController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShopScope>()!.notifier!;
}
