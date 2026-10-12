import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/shop_controller.dart';
import '../models/shop.dart';
import '../screens/bag.dart';

const emerald = Color(0xFF106B50);
const ink = Color(0xFF18231E);
const muted = Color(0xFF737972);
const paper = Color(0xFFFAFAF7);
const line = Color(0xFFE8E9E3);

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: 44,
      height: 44,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: OverflowBox(
          minWidth: 96,
          maxWidth: 96,
          minHeight: 96,
          maxHeight: 96,
          child: Transform.translate(
            offset: const Offset(0, 7),
            child: Image.asset(
              'assets/images/kerabasket_logo.png',
              width: 96,
              height: 96,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              color: emerald,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ),
      ),
    ),
  );
}

class PhotoAtlas {
  static ui.Image? image;
  static ui.Image? expanded;
  static Future<void> load() async {
    final data = await rootBundle.load('assets/images/products.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    image = (await codec.getNextFrame()).image;
    codec.dispose();
    final extra = await rootBundle.load('assets/images/catalog-expanded.png');
    final extraCodec = await ui.instantiateImageCodec(extra.buffer.asUint8List());
    expanded = (await extraCodec.getNextFrame()).image;
    extraCodec.dispose();
  }
}

class ProductPhoto extends StatelessWidget {
  final int photo;
  final double radius;
  final String? label;
  const ProductPhoto(this.photo, {super.key, this.radius = 12, this.label});
  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: label ?? 'Product photo',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(
        painter: _PhotoPainter(photo),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _PhotoPainter extends CustomPainter {
  final int photo;
  _PhotoPainter(this.photo);
  @override
  void paint(Canvas canvas, Size size) {
    final image = photo < 4 ? PhotoAtlas.image : PhotoAtlas.expanded;
    if (image == null) {
      canvas.drawRect(Offset.zero & size, Paint()..color = line);
      return;
    }
    final columns = photo < 4 ? 2 : 4;
    final rows = photo < 4 ? 2 : 5;
    final index = photo < 4 ? photo : photo - 4;
    final halfW = image.width / columns;
    final halfH = image.height / rows;
    final origin = Offset((index % columns) * halfW, (index ~/ columns) * halfH);
    final sizes = applyBoxFit(BoxFit.cover, Size(halfW, halfH), size);
    final source = Alignment.center.inscribe(
      sizes.source,
      origin & Size(halfW, halfH),
    );
    canvas.drawImageRect(
      image,
      source,
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_PhotoPainter oldDelegate) => oldDelegate.photo != photo;
}

class PageWidth extends StatelessWidget {
  final Widget child;
  final double max;
  final bool shrinkWrap;
  const PageWidth({
    super.key,
    required this.child,
    this.max = 1050,
    this.shrinkWrap = false,
  });
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    heightFactor: shrinkWrap ? 1 : null,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: max),
      child: child,
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool outline, busy;
  final IconData? icon;
  const PrimaryButton(
    this.text, {
    super.key,
    this.onPressed,
    this.outline = false,
    this.busy = false,
    this.icon,
  });
  @override
  Widget build(BuildContext context) {
    final child = busy
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: outline
          ? OutlinedButton(onPressed: busy ? null : onPressed, child: child)
          : FilledButton(onPressed: busy ? null : onPressed, child: child),
    );
  }
}

class BottomPanel extends StatelessWidget {
  final Widget child;
  const BottomPanel({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: line)),
    ),
    child: SafeArea(
      top: false,
      child: PageWidth(
        max: 720,
        shrinkWrap: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          child: child,
        ),
      ),
    ),
  );
}

class BagButton extends StatelessWidget {
  const BagButton({super.key});
  @override
  Widget build(BuildContext context) {
    final count = ShopScope.of(context).state.count;
    return IconButton(
      tooltip: 'Shopping bag',
      onPressed: () => openPage(context, const BagPage()),
      icon: Badge(
        isLabelVisible: count > 0,
        backgroundColor: emerald,
        label: Text('$count'),
        child: const Icon(Icons.shopping_bag_outlined),
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  final Product product;
  const SaveButton(this.product, {super.key});
  @override
  Widget build(BuildContext context) {
    final shop = ShopScope.of(context);
    final saved = shop.state.saved.contains(product.id);
    return IconButton(
      tooltip: saved ? 'Remove from saved' : 'Save item',
      onPressed: () => shop.toggleSaved(product.id),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: .94),
      ),
      icon: Icon(
        saved ? Icons.favorite : Icons.favorite_border,
        color: saved ? emerald : ink,
        size: 21,
      ),
    );
  }
}

class PriceLabel extends StatelessWidget {
  final Product product;
  final bool large;
  const PriceLabel(this.product, {super.key, this.large = false});
  @override
  Widget build(BuildContext context) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 7,
    runSpacing: 2,
    children: [
      Text(
        money(product.price),
        style: TextStyle(
          fontSize: large ? 25 : 17,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      Text(
        money(product.originalPrice),
        style: const TextStyle(
          fontSize: 12,
          color: muted,
          decoration: TextDecoration.lineThrough,
        ),
      ),
      Text(
        '${product.discount}% off',
        style: const TextStyle(
          fontSize: 12,
          color: emerald,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final String? action;
  final VoidCallback? onAction;
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.onAction,
  });
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFEAF1EB),
            child: Icon(icon, size: 32, color: emerald),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, height: 1.5),
          ),
          if (action != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: 230,
              child: PrimaryButton(action!, onPressed: onAction),
            ),
          ],
        ],
      ),
    ),
  );
}

class SummaryRow extends StatelessWidget {
  final String label, value;
  final bool strong, green;
  const SummaryRow(
    this.label,
    this.value, {
    super.key,
    this.strong = false,
    this.green = false,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: strong ? ink : muted,
              fontSize: strong ? 18 : 14,
              fontWeight: strong ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: green ? emerald : ink,
            fontSize: strong ? 20 : 14,
            fontWeight: strong || green ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

class StorageNotice extends StatelessWidget {
  const StorageNotice({super.key});
  @override
  Widget build(BuildContext context) {
    final text = ShopScope.of(context).storageError;
    return text == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Text(text, style: const TextStyle(color: Color(0xFF8A4900))),
          );
  }
}

Future<T?> openPage<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));
void toast(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
}
