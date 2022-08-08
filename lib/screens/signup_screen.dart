import 'package:flutter/material.dart';
import 'package:server_post/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import '../const.dart';
import 'home_screen.dart';

class Signup_Screen extends StatefulWidget {
  @override
  State<Signup_Screen> createState() => _Signup_ScreenState();
}

class _Signup_ScreenState extends State<Signup_Screen> {
  late TextEditingController usernamecontroller;
  late TextEditingController passwordcontroller;
  late TextEditingController firstnamecontroller;
  late TextEditingController lastnamecontroller;
  late TextEditingController emailcontroller;

  @override
  void initState() {
    usernamecontroller = TextEditingController();
    passwordcontroller = TextEditingController();
    firstnamecontroller = TextEditingController();
    lastnamecontroller = TextEditingController();
    emailcontroller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    usernamecontroller.dispose();
    passwordcontroller.dispose();
    firstnamecontroller.dispose();
    lastnamecontroller.dispose();
    emailcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: [
            TextField(
              controller: emailcontroller,
              decoration: InputDecoration(
                labelText: 'Email',
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
            TextField(
              controller: firstnamecontroller,
              decoration: InputDecoration(
                labelText: 'First Name',
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
              controller: lastnamecontroller,
              decoration: InputDecoration(
                labelText: 'Last Name',
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
            Container(
              width: 130,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () {
                  signup();
                },
                child: Text(
                  'Sign up',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Have Account?"),
                TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (BuildContext contex) {
                          return Login_Screen();
                        }),
                      );
                    },
                    child: Text('Log in!'))
              ],
            )
          ],
        ),
      ),
    );
  }

  void signup() async {
    String username = usernamecontroller.text;
    String password = passwordcontroller.text;
    String lastname = lastnamecontroller.text;
    String firstname = firstnamecontroller.text;
    String email = emailcontroller.text;

    if (username.isEmpty ||
        password.isEmpty ||
        lastname.isEmpty ||
        firstname.isEmpty ||
        email.isEmpty) {
      print('sth is empty');
    }

    http.Response response = await http.post(
      Uri.parse('$kBaseUrl/api/register/'),
      body: convert.json.encode(
        {
          'username': username,
          'password': password,
          'first_name': firstname,
          'last_name': lastname,
          'email': email,
        },
      ),
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
      },
    );
    print(response.statusCode);
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
      await pref.setString('username', map['username']);
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
}
