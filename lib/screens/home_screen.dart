import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:server_post/const.dart';
import 'package:server_post/models/post.dart';
import 'package:server_post/screens/add_post_screen.dart';
import 'package:server_post/screens/login_screen.dart';
import 'package:server_post/screens/show_post_screen.dart';
import 'package:server_post/widgets/post_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class Home_Screen extends StatefulWidget {
  String token;

  Home_Screen({required this.token});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
              onPressed: () async {
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) {
                    return Login_Screen();
                  }),
                );
              },
              icon: Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return Add_Post(
                  token: widget.token,
                  title: '',
                  description: '',
                  type: 'Add',
                  postid: -1,
                );
              },
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder(
            future: loadData(),
            builder:
                (BuildContext contex, AsyncSnapshot<http.Response> snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                http.Response response =
                    snapshot.data ?? http.Response('', 404);
                List list = convert.json.decode(response.body);
                return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map map = list[index];
                      Post post = Post(
                        text: map['title'],
                        description: map['description'],
                        id: map['id'],
                        imageurl: map['image'],
                      );
                      return Post_Item(
                          post: post,
                          onDeletePressed: () {
                            delete(map['id']);
                            setState(() {});
                          },
                          onUpdatePressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return ShowPost_Item(
                                  token: widget.token,
                                  postid: map['id'],
                                );
                              }),
                            );
                          });
                    });
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }

  Future<http.Response> loadData() async {
    http.Response response = await http.get(
      Uri.parse('$kBaseUrl/api/post/all/'),
      headers: {
        HttpHeaders.authorizationHeader: widget.token,
      },
    );
    return response;
  }

  Future<bool> delete(int index) async {
    try {
      http.Response response = await http.delete(
        Uri.parse('$kBaseUrl/api/post/delete/$index/'),
        headers: {
          HttpHeaders.authorizationHeader: widget.token,
        },
      );
      if (response.statusCode == 403) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('You are not the post creator!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            });
      }
      else if (response.statusCode == 200) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text('Post deleted successfully'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            });
      }
      print(response.statusCode);
      print(response.body);
      return true;
    } //
    catch (e) {
      print(e);
      return false;
    }
  }
}
