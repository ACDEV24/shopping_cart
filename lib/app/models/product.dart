class Product {

  final String id;
  final bool active;
  final String name;
  final String picture;
  final String carsID;
  final int price;
  final int stock;
  final int carQuantity;

  Product({
    this.id = '',
    this.active = false,
    this.name = '',
    this.picture = '',
    this.carsID = '',
    this.price = 0,
    this.stock = 0,
    this.carQuantity = 0,
  });

  Product copyWith({
    String id,
    bool active,
    String name,
    String picture,
    String carsID,
    int price,
    int stock,
    int carQuantity,
  }) => Product(
    id: id ?? this.id,
    active: active ?? this.active,
    name: name ?? this.name,
    picture: picture ?? this.picture,
    carsID: carsID ?? this.carsID,
    price: price ?? this.price,
    stock: stock ?? this.stock,
    carQuantity: carQuantity ?? this.carQuantity,
  );

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id:       (json['id']       == null) ? '' : json['id'],
    active:   (json['active']   == null) ? false : json['active'],
    name:     (json['name']     == null) ? '' : json['name'],
    picture:  (json['picture']  == null) ? '' : json['picture'],
    price:    (json['price']    == null) ? 0 : json['price'],
    stock:    (json['stock']    == null) ? 0 : json['stock'],
  );

  int get totalPrice => this.price * this.carQuantity;
}
