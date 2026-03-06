class FoodSuggestionResponse {
  List<FoodItem>? items;

  FoodSuggestionResponse({this.items});

  FoodSuggestionResponse.fromJson(dynamic json) {
    if (json is List) {
      items = json.map((e) => FoodItem.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (items != null) {
      data['items'] = items!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class FoodItem {
  int? id;
  String? name;
  String? image;

  FoodItem({this.id, this.name, this.image});

  FoodItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}
