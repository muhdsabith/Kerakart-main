class Product {
  final String id, name, category, description, material;
  final int price, originalPrice, photo, reviews;
  final double rating;
  final List<String> sizes;
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.material,
    required this.price,
    required this.originalPrice,
    required this.photo,
    required this.rating,
    required this.reviews,
    this.sizes = const ['One size'],
  });
  int get discount => ((1 - price / originalPrice) * 100).round();
}

class BagItem {
  final String productId, size;
  final int quantity;
  const BagItem(this.productId, this.size, this.quantity);
  String get key => '$productId|$size';
  BagItem withQuantity(int value) => BagItem(productId, size, value);
  Map<String, dynamic> toJson() => {
    'productId': productId,
    'size': size,
    'quantity': quantity,
  };
}

class Address {
  final String name, phone, street, city, pin;
  const Address({
    this.name = '',
    this.phone = '',
    this.street = '',
    this.city = '',
    this.pin = '',
  });
  String get summary => '$street, $city, Kerala $pin';
  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'street': street,
    'city': city,
    'pin': pin,
  };
  factory Address.fromJson(Map<String, dynamic> json) => Address(
    name: json['name'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    street: json['street'] as String? ?? '',
    city: json['city'] as String? ?? '',
    pin: json['pin'] as String? ?? '',
  );
}

class DemoOrder {
  final String id, date, method;
  final List<BagItem> items;
  final int subtotal, discount, total;
  final Address address;
  const DemoOrder({
    required this.id,
    required this.date,
    required this.method,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.address,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'method': method,
    'items': items.map((e) => e.toJson()).toList(),
    'subtotal': subtotal,
    'discount': discount,
    'total': total,
    'address': address.toJson(),
  };
  factory DemoOrder.fromJson(Map<String, dynamic> j) => DemoOrder(
    id: j['id'] as String,
    date: j['date'] as String,
    method: j['method'] as String,
    items: (j['items'] as List)
        .map(
          (e) => BagItem(
            e['productId'] as String,
            e['size'] as String,
            e['quantity'] as int,
          ),
        )
        .toList(),
    subtotal: j['subtotal'] as int,
    discount: j['discount'] as int,
    total: j['total'] as int,
    address: Address.fromJson(Map<String, dynamic>.from(j['address'] as Map)),
  );
}

String money(int value) {
  final text = value.toString();
  if (text.length <= 3) return '₹$text';
  final last = text.substring(text.length - 3);
  final first = text.substring(0, text.length - 3);
  final grouped = first.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{2})+$)'),
    (m) => '${m[1]},',
  );
  return '₹$grouped,$last';
}
