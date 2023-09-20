class Product {
  String barcode;
  String image;
  String name;
  double mrp;
  double price;
  String quantity;
  int count;
  String description;
  String category;

  Product(
      {required this.barcode,
      required this.image,
      required this.name,
      required this.mrp,
      required this.price,
      required this.quantity,
      required this.count,
      required this.description,
      required this.category});
//fetching product index wise
  static Product IndexData(i) {
    //code to iterator Product index wise
    return Product(
        barcode: '',
        category: '',
        count: 0,
        description: '',
        image: '',
        mrp: 0,
        name: '',
        price: 0,
        quantity: '');
  }

  static Product fromJson(i) {
    return Product(
        barcode: '',
        category: '',
        count: 0,
        description: '',
        image: '',
        mrp: 0,
        name: '',
        price: 0,
        quantity: '');
  }
}
