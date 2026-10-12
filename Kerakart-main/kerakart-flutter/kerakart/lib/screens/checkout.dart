import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/catalog.dart';
import '../data/shop_controller.dart';
import '../models/shop.dart';
import '../widgets/common.dart';
import 'account.dart';

class AddressEditor extends StatefulWidget {
  final Address initial;
  const AddressEditor({super.key, required this.initial});
  @override
  State<AddressEditor> createState() => _AddressEditorState();
}

class _AddressEditorState extends State<AddressEditor> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.initial.name);
  late final phone = TextEditingController(text: widget.initial.phone);
  late final street = TextEditingController(text: widget.initial.street);
  late final city = TextEditingController(text: widget.initial.city);
  late final pin = TextEditingController(text: widget.initial.pin);
  @override
  void dispose() {
    for (final c in [name, phone, street, city, pin]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Delivery Address')),
    body: PageWidth(
      max: 720,
      child: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const Text(
              'Where should it feel like home?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'This demo saves your address only on this device.',
              style: TextStyle(color: muted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 26),
            field(name, 'Full Name', hints: [AutofillHints.name]),
            const SizedBox(height: 18),
            field(
              phone,
              'Mobile Number',
              keyboard: TextInputType.phone,
              digits: 10,
              hints: [AutofillHints.telephoneNumberNational],
              validator: (v) =>
                  RegExp(r'^[6-9]\d{9}$').hasMatch(v?.trim() ?? '')
                  ? null
                  : 'Enter a valid 10-digit mobile number',
            ),
            const SizedBox(height: 18),
            field(
              street,
              'House, Street & Area',
              hints: [AutofillHints.fullStreetAddress],
              lines: 2,
            ),
            const SizedBox(height: 18),
            field(city, 'City / Town', hints: [AutofillHints.addressCity]),
            const SizedBox(height: 18),
            field(
              pin,
              'PIN Code',
              keyboard: TextInputType.number,
              digits: 6,
              hints: [AutofillHints.postalCode],
              validator: (v) =>
                  RegExp(r'^[1-9]\d{5}$').hasMatch(v?.trim() ?? '')
                  ? null
                  : 'Enter a valid 6-digit PIN Code',
            ),
            const SizedBox(height: 18),
            const InputDecorator(
              decoration: InputDecoration(labelText: 'State'),
              child: Text('Kerala'),
            ),
            const SizedBox(height: 26),
            PrimaryButton(
              'Save Address',
              onPressed: () {
                if (!form.currentState!.validate()) return;
                final address = Address(
                  name: name.text.trim(),
                  phone: phone.text.trim(),
                  street: street.text.trim(),
                  city: city.text.trim(),
                  pin: pin.text.trim(),
                );
                ShopScope.of(context).address(address);
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    ),
  );
  Widget field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboard,
    int? digits,
    int lines = 1,
    List<String>? hints,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboard,
    maxLines: lines,
    autofillHints: hints,
    textCapitalization: keyboard == null
        ? TextCapitalization.words
        : TextCapitalization.none,
    inputFormatters: digits == null
        ? null
        : [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(digits),
          ],
    decoration: InputDecoration(labelText: label),
    validator:
        validator ??
        (v) => (v?.trim().isEmpty ?? true)
            ? 'Please enter ${label.toLowerCase()}'
            : null,
  );
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String method = 'UPI';
  bool busy = false, review = false;
  Future<void> continueCheckout() async {
    final shop = ShopScope.of(context);
    if (shop.state.address.name.isEmpty) {
      await openPage(context, AddressEditor(initial: shop.state.address));
      return;
    }
    if (!review) {
      setState(() => review = true);
      return;
    }
    setState(() => busy = true);
    try {
      final order = await shop.placeDemoOrder(method);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SuccessPage(order: order)),
      );
    } catch (_) {
      if (mounted) {
        setState(() => busy = false);
        toast(
          context,
          'Could not save this order. Check your address and device storage, then try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ShopScope.of(context).state;
    final address = state.address;
    return PopScope(
      canPop: !busy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(review ? 'Review Order' : 'Checkout'),
          automaticallyImplyLeading: !busy,
        ),
        body: state.bag.isEmpty
            ? const EmptyView(
                icon: Icons.shopping_bag_outlined,
                title: 'Your bag is empty',
                subtitle: 'Choose something you love before checking out.',
              )
            : PageWidth(
                max: 720,
                child: ListView(
                  padding: const EdgeInsets.all(22),
                  children: [
                    Row(
                      children: [
                        step('Address', 1, address.name.isNotEmpty),
                        const Expanded(child: Divider()),
                        step('Payment', 2, !review && address.name.isNotEmpty),
                        const Expanded(child: Divider()),
                        step('Review', 3, review),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2EC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: emerald, size: 18),
                          SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'Demo checkout. No money is charged and no items will be shipped.',
                              style: TextStyle(
                                color: emerald,
                                height: 1.5,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: line),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: emerald,
                        ),
                        title: Text(
                          address.name.isEmpty
                              ? 'Add your delivery address'
                              : address.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: address.name.isEmpty
                            ? const Text(
                                'Kerala, India',
                                style: TextStyle(fontSize: 12),
                              )
                            : Text(
                                '${address.summary}\n+91 ${address.phone}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: muted,
                                ),
                              ),
                        trailing: const Icon(
                          Icons.edit_outlined,
                          size: 19,
                          color: emerald,
                        ),
                        onTap: busy
                            ? null
                            : () async {
                                await openPage(
                                  context,
                                  AddressEditor(initial: address),
                                );
                                if (mounted) setState(() => review = false);
                              },
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Payment method',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: line),
                      ),
                      child: Column(
                        children: [
                          payment(
                            'UPI',
                            'Google Pay, PhonePe, Paytm',
                            Icons.qr_code_rounded,
                          ),
                          const Divider(height: 1),
                          payment(
                            'Card',
                            'Credit / debit card',
                            Icons.credit_card_outlined,
                          ),
                          const Divider(height: 1),
                          payment(
                            'Cash on delivery',
                            'Pay when your order arrives',
                            Icons.payments_outlined,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Payment choices are for preview only. No payment details are collected.',
                      style: TextStyle(fontSize: 11, color: muted, height: 1.4),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Order summary (${state.count} items)',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...state.bag.map((item) {
                      final p = productById(item.productId);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 54,
                              height: 64,
                              child: ProductPhoto(
                                p.photo,
                                label: p.name,
                                radius: 8,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                            const SizedBox(width: 8),
                            Text(
                              money(p.price * item.quantity),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(),
                    SummaryRow('Subtotal', money(state.subtotal)),
                    const SummaryRow('Delivery', 'FREE', green: true),
                    if (state.discount > 0)
                      SummaryRow(
                        'KERA10 discount',
                        '−${money(state.discount)}',
                        green: true,
                      ),
                    const Divider(),
                    SummaryRow('Total', money(state.total), strong: true),
                    const SizedBox(height: 12),
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
                      address.name.isEmpty
                          ? 'Add Delivery Address'
                          : review
                          ? 'Place Demo Order · ${money(state.total)}'
                          : 'Review Order',
                      onPressed: continueCheckout,
                      busy: busy,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Saved on this device • No real transaction',
                      style: TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget step(String label, int number, bool active) => Column(
    children: [
      CircleAvatar(
        radius: 14,
        backgroundColor: active ? emerald : line,
        child: Text(
          '$number',
          style: TextStyle(fontSize: 12, color: active ? Colors.white : muted),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: TextStyle(fontSize: 11, color: active ? emerald : muted),
      ),
    ],
  );
  Widget payment(String title, String subtitle, IconData icon) => ListTile(
    enabled: !busy,
    onTap: busy
        ? null
        : () => setState(() {
            method = title;
            review = false;
          }),
    leading: Icon(icon, size: 23, color: method == title ? emerald : muted),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    ),
    subtitle: Text(
      subtitle,
      style: const TextStyle(fontSize: 11, color: muted),
    ),
    trailing: Icon(
      method == title ? Icons.radio_button_checked : Icons.radio_button_off,
      color: method == title ? emerald : muted,
      size: 21,
    ),
  );
}

class SuccessPage extends StatelessWidget {
  final DemoOrder order;
  const SuccessPage({super.key, required this.order});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('KeraBasket'),
    ),
    body: PageWidth(
      max: 640,
      child: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          const SizedBox(height: 36),
          const CircleAvatar(
            radius: 46,
            backgroundColor: Color(0xFFEAF2EC),
            child: Icon(Icons.check_rounded, size: 48, color: emerald),
          ),
          const SizedBox(height: 25),
          const Text(
            'A lovely choice.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'serif', fontSize: 37, color: ink),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your demo order is saved.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          const Text(
            'This is a preview purchase. No payment was taken and no shipment will be created.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, height: 1.6),
          ),
          const SizedBox(height: 32),
          SummaryRow('Order total', money(order.total), strong: true),
          SummaryRow('Payment choice', order.method),
          const SizedBox(height: 8),
          Text(
            order.id,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            'Continue shopping',
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            'View my orders',
            outline: true,
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OrdersPage()),
            ),
          ),
        ],
      ),
    ),
  );
}
