import 'package:flutter_weather/models/weather_model.dart';
import 'package:dio/dio.dart';

class WeatherService {
  Future<Weather> getWeatherDetails(
      {String location = '',
      double lat = 0.0,
      double lon = 0.0,
      String lang = 'en'}) async {
    var url = 'https://api.openweathermap.org/data/2.5/';
    var apiKey = '8a33f19a6f6704061f1f4f21bed94901';
    var units =
        'metric'; // for celcius | imperial for fahrenheit | standard for kelvin (default)
    if (location == '') {
      lat == 0.0 && lon == 0.0
          ? location = 'q=Baku'
          : location = 'lat=$lat&lon=$lon';
    } else {
      location = 'q=$location';
    }
    var res = await Dio()
        .get('$url/weather?$location&units=$units&lang=$lang&appid=$apiKey');
    return Weather.fromJson(res.data);
  }
}
