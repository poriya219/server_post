import 'package:flutter/material.dart';
import 'package:server_post/const.dart';
import 'package:server_post/screens/home_screen.dart';
import 'package:server_post/screens/signup_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:shared_preferences/shared_preferences.dart';

class Login_Screen extends StatefulWidget {
  @override
  State<Login_Screen> createState() => _Login_ScreenState();
}

class _Login_ScreenState extends State<Login_Screen> {
  late TextEditingController usernamecontroller;
  late TextEditingController passwordcontroller;

  @override
  void initState() {
    usernamecontroller = TextEditingController();
    passwordcontroller = TextEditingController();
    checkTokenHaveData();
    super.initState();
  }

  @override
  void dispose() {
    usernamecontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: [
            TextField(
              controller: usernamecontroller,
              decoration: InputDecoration(
                labelText: 'Username',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextField(
              controller: passwordcontroller,
              decoration: InputDecoration(
                labelText: 'Password',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 15),
            Container(
              width: 130,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () {
                  login();
                },
                child: Text(
                  'Log in',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't Have Account?"),
                TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (BuildContext contex) {
                          return Signup_Screen();
                        }),
                      );
                    },
                    child: Text('Sign up now!'))
              ],
            )
          ],
        ),
      ),
    );
  }

  void login() async {
    String username = usernamecontroller.text;
    String password = passwordcontroller.text;

    if (username.isEmpty || password.isEmpty) {
      print('sth is empty');
    }

    http.Response response = await http.post(
      Uri.parse('$kBaseUrl/api/login/'),
      body: convert.json.encode(
        {
          'username': username,
          'password': password,
        },
      ),
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
      },
    );
    Map responsemap = convert.json.decode(response.body);
    String token = await savetoLocal(responsemap);
    if (token != '-1') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) {
          return Home_Screen(
            token: token,
          );
        }),
      );
    }
  }

  Future<String> savetoLocal(Map map) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString('username', map['user_name']);
      String token = 'Token ${map['token']}';
      await pref.setString('token', token);
      await pref.setInt('id', map['id']);
      await pref.setString(
          'fullname', '${map['first_name']} ${map['last_name']}');
      return token;
    } //
    catch (e) {
      return '-1';
    }
  }

  void checkTokenHaveData() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      if (pref.containsKey('token')) {
        String token = pref.getString('token') ?? '-1';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) {
            return Home_Screen(
              token: token,
            );
          }),
        );
      }
    } //
    catch (e) {}
  }
}
