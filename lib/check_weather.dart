import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class CheckWeather extends StatefulWidget {
  const CheckWeather({super.key});

  @override
  State<CheckWeather> createState() => _CheckWeatherState();
}

class _CheckWeatherState extends State<CheckWeather> {
  TextEditingController _controllerCity = TextEditingController();
  EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences();
  final GlobalKey<FormState> _formKey = GlobalKey();

  bool _searching = false;
  bool _showResult = false;
  String _baseURL = 'api.weatherapi.com';

  var _currentWeather;

  void update(bool success, String message) {
    if(success) {
      setState(() {
        _searching = false;
        _showResult = true;
      });
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        _searching = false;
        _showResult = false;
      });
    }
  }

  void getWeatherPerCity(String city) async {
    try {
      String token = await _encryptedData.getString('token');
      final url = Uri.https(_baseURL, '/v1/current.json', {'key': '$token', 'q': '$city', 'aqi': 'no'});
      final response = await http.get(url)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonResponse = convert.jsonDecode(response.body);
        print(jsonResponse['current']);
        _currentWeather = jsonResponse['current'];
        update(true, "Found");
      }
      else
        update(false, "No matching location found");
    }
    catch(e) {
      print('Error : ${e.toString()}');
      update(false, "Error fetching data");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(onPressed: () {
          _encryptedData.remove('token').then((success) =>
              Navigator.of(context).pop());
        }, icon: const Icon(Icons.logout))
      ],
        automaticallyImplyLeading: false,
        title: Text('Weather'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(child: Center(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20.0,),
              SizedBox(width: screenWidth *0.8,
                  child: TextFormField(controller: _controllerCity,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Enter City"),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a city';
                      }
                      return null;
                    },
                  )
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: _searching ? null : () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _searching = true;
                      });
                      getWeatherPerCity(_controllerCity.text.toString());
                    }
                  },
                child: const Text('Get Weather'),
              ),
              const SizedBox(height: 20),
              Visibility(visible: _searching, child: CircularProgressIndicator()),
              _showResult ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10.0,),
                    Text("${_currentWeather['temp_c']} °", style: TextStyle(fontSize: 30),),
                    SizedBox(height: 5.0,),
                    Text("Feels like: ${_currentWeather['feelslike_c']} °", style: TextStyle(fontSize: 30),),
                    SizedBox(height: 5.0,),
                    SizedBox(width: screenWidth*0.7,
                        child: Text(
                            "Wind: ${_currentWeather['wind_kph']} km/h",
                            style: TextStyle(fontSize: 30),
                            textAlign: TextAlign.center)),
                    SizedBox(height: 5.0,),
                    SizedBox(width: screenWidth*0.7,
                        child: Text(
                            "Humidity: ${_currentWeather['humidity']}%",
                            style: TextStyle(fontSize: 30),
                            textAlign: TextAlign.center)),
                    SizedBox(height: 5.0,),
                    Image.network(
                      'https:${_currentWeather['condition']['icon']}',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 5.0,),
                    SizedBox(width: screenWidth*0.7,
                        child: Text(
                          "${_currentWeather['condition']['text']}",
                            style: TextStyle(fontSize: 30),
                            textAlign: TextAlign.center)),
                  ],
                ) : Text(""),
            ],
          ),
        )
      ),)
    );
  }
}