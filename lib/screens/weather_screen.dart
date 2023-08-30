// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_weather/constants/languages.dart';
import 'package:flutter_weather/constants/terms_translations.dart';
import 'package:flutter_weather/models/weather_model.dart';
import 'package:flutter_weather/services/weather_service.dart';
import 'package:geolocator/geolocator.dart';

import 'package:material_symbols_icons/symbols.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Position? _currentPosition;
  String cityName = '';
  String selectedValue = 'en';

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: TextField(
        autofocus: true,
        style: TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: 'Enter city name',
          hintStyle: TextStyle(
            color: Colors.white,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.white.withOpacity(0.3),
        ),
        onSubmitted: (value) {
          setState(() {
            cityName = value;
          });
          Navigator.of(context).pop();
          build(context);
        },
      ),
    );
    return Scaffold(
      body: _currentPosition != null
          ? FutureBuilder(
              future: WeatherService().getWeatherDetails(
                  location: cityName,
                  lat: _currentPosition?.latitude ?? 0,
                  lon: _currentPosition?.longitude ?? 0,
                  lang: selectedValue),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Something went wrong!'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                Weather weather = snapshot.data;
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/${weather.main!.temp! > 19 ? 'warm-bg.jpg' : 'cold-bg.jpeg'}',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                dropdownColor: Colors.black.withOpacity(0.6),
                                elevation: 0,
                                value: selectedValue,
                                onChanged: (value) {
                                  setState(() {
                                    selectedValue = value.toString();
                                  });
                                  build(context);
                                },
                                underline: SizedBox(),
                                items: languages.entries
                                    .map((e) => DropdownMenuItem(
                                          value: e.key,
                                          child: Text(e.value),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${weather.name}, ${weather.sys!.country}',
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return alert;
                                                    },
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.search,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Stack(children: [
                                            Text(
                                              '${weather.main!.temp!.toStringAsFixed(0)} ',
                                              style: TextStyle(
                                                fontSize: 100,
                                                color: Colors.white,
                                              ),
                                              textScaleFactor: 2,
                                            ),
                                            Positioned(
                                              right: 0,
                                              child: Text(
                                                '°',
                                                style: TextStyle(
                                                  fontSize: 100,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ]),
                                        ],
                                      ),
                                    ),
                                    RotatedBox(
                                      quarterTurns: -1,
                                      child: Text(
                                        weather.weather![0].description!,
                                        style: TextStyle(
                                          fontSize: 26,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Icon(Symbols.humidity_percentage,
                                        color: Colors.white, size: 30),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${weather.main!.humidity!.toString()}%',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      termTranslations['humidity']![
                                              selectedValue] ??
                                          'Humidity',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Icon(Symbols.visibility,
                                        color: Colors.white, size: 30),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${(weather.visibility! / 1000).toStringAsFixed(1)} km',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      termTranslations['visibility']![
                                              selectedValue] ??
                                          'Visibility',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Icon(Symbols.air,
                                        color: Colors.white, size: 30),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${(weather.wind!.speed! * 3.6).toStringAsFixed(1)} km/h',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      termTranslations['wind']![
                                              selectedValue] ??
                                          'Wind',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Please allow the app to access your location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _getCurrentPosition,
                    child: Text('Allow location access'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }
}
