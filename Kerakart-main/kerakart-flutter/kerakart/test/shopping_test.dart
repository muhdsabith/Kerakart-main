import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kerakart/data/shop_controller.dart';
import 'package:kerakart/data/shop_state.dart';
import 'package:kerakart/main.dart';
import 'package:kerakart/widgets/common.dart';
import '../tool/state_checks.dart' as checks;

void main() {
  test('Shopping rules and persisted order snapshots', checks.main);
  testWidgets('Browse, add to bag, enter address and save a demo order', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final prefs = await SharedPreferences.getInstance();
    final shop = ShopController(prefs, ShopState());
    await tester.runAsync(PhotoAtlas.load);
    await tester.pumpWidget(KeraBasketApp(controller: shop));
    await tester.pumpAndSettle();
    expect(find.text('KeraBasket'), findsOneWidget);
    expect(find.byType(BrandMark), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Everyday Cotton Kurta'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Everyday Cotton Kurta'), findsOneWidget);
    await tester.tap(find.text('Everyday Cotton Kurta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add To Bag'));
    await tester.pumpAndSettle();
    expect(shop.state.count, 1);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Shopping bag').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue To Checkout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Delivery Address'));
    await tester.pumpAndSettle();
    Future<void> enter(String label, String value) async {
      final field = find.widgetWithText(TextFormField, label);
      await tester.scrollUntilVisible(
        field,
        160,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.enterText(field, value);
    }

    await enter('Full Name', 'Demo Customer');
    await enter('Mobile Number', '9000000000');
    await enter('House, Street & Area', 'Sample house');
    await enter('City / Town', 'Malappuram');
    await enter('PIN Code', '676505');
    await tester.scrollUntilVisible(
      find.text('Save Address'),
      160,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Save Address'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Review Order'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Place Demo Order · ₹799'));
    await tester.pumpAndSettle();
    expect(shop.state.orders.length, 1);
    expect(shop.state.bag, isEmpty);
    expect(find.text('Your demo order is saved.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final restored = await ShopController.load();
    expect(restored.state.orders.single.total, 799);
  });
  testWidgets('Small phone search and saved items work', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final shop = ShopController(
      await SharedPreferences.getInstance(),
      ShopState(),
    );
    await tester.runAsync(PhotoAtlas.load);
    await tester.pumpWidget(KeraBasketApp(controller: shop));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField).first, 'mug');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Slow Morning Mug'), findsOneWidget);
    await tester.tap(find.byTooltip('Save item').first);
    await tester.pumpAndSettle();
    expect(shop.state.saved, contains('mug'));
    expect(tester.takeException(), isNull);
  });
  for (final textScale in [1.0, 1.5, 2.0]) {
    testWidgets('Narrow catalog fits at text scale $textScale', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final shop = ShopController(
        await SharedPreferences.getInstance(),
        ShopState(),
      );
      await tester.runAsync(PhotoAtlas.load);
      await tester.pumpWidget(KeraBasketApp(controller: shop));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextField).first, 'mug');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Slow Morning Mug'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Slow Morning Mug'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
