class ShopsProduct {
  String? imageurl;
  String? productName;
  String? brand;
  String? offerPrice;
  String? category;
  String? stats;
  String? createdDate;

  ShopsProduct({
    this.imageurl,
    this.productName,
    this.brand,
    this.offerPrice,
    this.category,
    this.stats,
    this.createdDate,
  });

  ShopsProduct.fromJson(Map<String, dynamic> json) {
    imageurl = json['imageurl'];
    productName = json['productName'];
    brand = json['brand'];
    offerPrice = json['offerPrice'];
    category = json['category'];
    stats = json['stats'];
    createdDate = json['createdDate'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['imageurl'] = imageurl;
    data['productName'] = productName;
    data['brand'] = brand;
    data['offerPrice'] = offerPrice;
    data['category'] = category;
    data['stats'] = stats;
    data['createdDate'] = createdDate;
    return data;
  }
}
