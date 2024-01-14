import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'check_weather.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final TextEditingController _controller = TextEditingController(); // hold token from TextField
  final EncryptedSharedPreferences _encryptedData = EncryptedSharedPreferences(); // used to store the api token later

  @override
  void initState() {
    super.initState();
    checkSavedToken();
  }

  void checkSavedToken() {
    _encryptedData.getString('token').then((String myKey) {
      if (myKey.isNotEmpty) {
        Navigator.of(context)
            .push(MaterialPageRoute(
            builder: (context) => const CheckWeather()));
      }
    });
  }

  void login() {
    if (_controller.text.toString().trim() == '') {
      update(false);
    } else {
      _encryptedData
          .setString('token', _controller.text.toString())
          .then((bool success) { // then is equivalent to using wait
        if (success) {
          update(true);
        } else {
          update(false);
        }
      });
    }
  }

  void update(bool success) {
    if (success) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const CheckWeather()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to set key')));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        centerTitle: true,
      ),
      body: Center(
          child: Column(children: [
            const SizedBox(height: 10),
            SizedBox(
                width: 200,
                child: TextField(
                  // replace typed text with * for passwords
                  obscureText: true,
                  enableSuggestions: false, // disable suggestions for password
                  autocorrect: false, // disable auto correct for password
                  controller: _controller,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Enter API Token'),
                )),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: login, child: const Text('Save'))
          ])),
    );
  }

}
