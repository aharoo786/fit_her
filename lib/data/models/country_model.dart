import 'package:fitness_zone_2/data/models/api_response/api_response_model.dart';

class Country {
  final int id;
  final String code;
  final String name;

  Country({
    required this.id,
    required this.code,
    required this.name,
  });

  // Factory constructor to create a Country instance from JSON
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  // Method to convert a Country instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}

// If you have a list of countries, you can create a function to parse it
class CountryList extends Serializable {
  final List<Country> countries;

  CountryList({required this.countries});

  // Factory constructor to create a CountryList instance from JSON
  factory CountryList.fromJson(Map<String, dynamic> json) {
    var countriesJson = json['countries'] as List;
    List<Country> countryList =
        countriesJson.map((country) => Country.fromJson(country)).toList();

    return CountryList(countries: countryList);
  }

  // Method to convert a CountryList instance to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'countries': countries.map((country) => country.toJson()).toList(),
    };
  }
}
