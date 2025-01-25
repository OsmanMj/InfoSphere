import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  TextEditingController _cityController = TextEditingController();
  String _temperature = '';
  String _weatherDescription = '';
  String _errorMessage = '';
  bool _isLoading = false;
  String _weatherIcon = '';
  String _humidity = '';
  String _windSpeed = '';
  String _pressure = '';
  String _iconUrl = '';
  List<String> _favoriteCities = [];

  Future<void> fetchWeather(String city) async {
    final apiKey = '5fe571f92a72d7da53ac683b058a5747';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=tr';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final temperature = data['main']['temp'].toString();
        final description = data['weather'][0]['description'];
        final icon = data['weather'][0]['icon'];
        final humidity = data['main']['humidity'].toString();
        final windSpeed = data['wind']['speed'].toString();
        final pressure = data['main']['pressure'].toString();

        setState(() {
          _temperature = temperature;
          _weatherDescription = description;
          _weatherIcon = icon;
          _humidity = humidity;
          _windSpeed = windSpeed;
          _pressure = pressure;
          _iconUrl = 'https://openweathermap.org/img/wn/$icon@2x.png';
          _errorMessage = '';
        });
      } else {
        setState(() {
          _errorMessage = 'Fazla yüklenemedi. Lütfen tekrar deneyin.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Bağlantı hatası oluştu. Lütfen tekrar deneyin.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> addCityToFavorites(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteCities.add(city);
    });
    prefs.setStringList('favoriteCities', _favoriteCities);
  }

  Future<void> deleteCityFromFavorites(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteCities.remove(city);
    });
    prefs.setStringList('favoriteCities', _favoriteCities);
  }

  Future<void> loadFavoriteCities() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteCities = prefs.getStringList('favoriteCities') ?? [];
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadFavoriteCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hava Durumu', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 5,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Şehir isimini Gir',
                    labelStyle: TextStyle(color: Colors.deepOrangeAccent),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.7),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      fetchWeather(value);
                    }
                  },
                ),
                SizedBox(height: 20),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _temperature.isNotEmpty
                        ? Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: const Color.fromARGB(255, 255, 255, 255)
                                .withOpacity(0.7),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'assets/loading.gif',
                                      image: _iconUrl,
                                      width: 100,
                                      height: 100,
                                      fadeInDuration:
                                          Duration(milliseconds: 500),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Sıcaklık: $_temperature°C',
                                    style: TextStyle(
                                        fontSize: 32,
                                        color: Colors.deepOrangeAccent),
                                  ),
                                  Text(
                                    'Durum: $_weatherDescription',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: const Color.fromARGB(
                                            255, 126, 126, 126)),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(Icons.water_drop,
                                          color: Colors.blue),
                                      SizedBox(width: 10),
                                      Text(
                                        'Nem: $_humidity%',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.deepOrangeAccent),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.air, color: Colors.grey),
                                      SizedBox(width: 10),
                                      Text(
                                        'Rüzgar Hızı: $_windSpeed m/s',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.deepOrangeAccent),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.compress,
                                          color: Colors.orange),
                                      SizedBox(width: 10),
                                      Text(
                                        'Basınç: $_pressure hPa',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.deepOrangeAccent),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                SizedBox(height: 20),
                Text(
                  'Favori Şehirler:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _favoriteCities.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(_favoriteCities[index]),
                          onTap: () {
                            fetchWeather(_favoriteCities[
                                index]); // عند الضغط على البطاقة يتم جلب بيانات الطقس
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.delete,
                                color: const Color.fromARGB(255, 255, 17, 0)),
                            onPressed: () {
                              // نافذة تحقق قبل الحذف
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title:
                                      Text('Silmek istediğinize emin misiniz?'),
                                  content: Text(
                                      'Bu şehri favorilerden silmek istediğinizden emin misiniz?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // إغلاق الحوار
                                      },
                                      child: Text('İptal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        deleteCityFromFavorites(
                                            _favoriteCities[index]);
                                        Navigator.of(context)
                                            .pop(); // إغلاق الحوار
                                      },
                                      child: Text(
                                        'Sil',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                if (_cityController.text.isNotEmpty) {
                  addCityToFavorites(_cityController.text);
                }
              },
              label: Text('Add to Favorite'),
              icon: Icon(
                Icons.favorite,
                color: Colors.white,
              ),
              backgroundColor: Colors.deepOrangeAccent,
            ),
          ),
        ],
      ),
    );
  }
}
