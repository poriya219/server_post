import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:server_post/const.dart';
import 'package:server_post/screens/add_post_screen.dart';

class ShowPost_Item extends StatefulWidget {
  int postid;
  String token;

  ShowPost_Item({required this.postid, required this.token});

  @override
  State<ShowPost_Item> createState() => _ShowPost_ItemState();
}

class _ShowPost_ItemState extends State<ShowPost_Item> {
  late Size size;
  String text = '';
  late String description;
  late String imageUrl;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text(''),
          actions: [
            IconButton(
              tooltip: 'edit post',
              onPressed: () {
                if(text.isNotEmpty){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return Add_Post(
                          token: widget.token,
                          title: text,
                          description: description,
                          type: 'Edit',
                          postid: widget.postid,
                        );
                      },
                    ),
                  );
                }
              },
              icon: Icon(Icons.edit),
            ),
          ],
        ),
        body: FutureBuilder(
            future: loadPost(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                http.Response response =
                    snapshot.data ?? http.Response('', 404);
                Map map = convert.json.decode(response.body);
                text = map['title'];
                description = map['description'];
                imageUrl = map['image'] ?? '';
                return SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        FadeInImage(
                          width: size.width * 0.7,
                          placeholder:
                              const AssetImage('assets/images/default.png'),
                          image: showPostImage(),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(text),
                        SizedBox(
                          height: 15,
                        ),
                        Text(description),
                      ],
                    ),
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }

  Future<http.Response> loadPost() async {
    http.Response response = await http.get(
      Uri.parse('$kBaseUrl/api/post/get/${widget.postid}'),
      headers: {
        HttpHeaders.authorizationHeader: widget.token,
      },
    );
    print(response.statusCode);
    print(response.body);
    return response;
  }

  NetworkImage showPostImage() {
    if (imageUrl != '') {
      return NetworkImage('$kBaseUrl/$imageUrl');
    } else {
      return NetworkImage(
          'http://industrelec.com/wp-content/plugins/lightbox/images/No-image-found.jpg');
    }
  }
}
