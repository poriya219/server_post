import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:server_post/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class Add_Post extends StatefulWidget {
  String token;
  String title;
  String description;
  String type;
  int postid;

  Add_Post({required this.token, required this.description, required this.title, required this.type,required this.postid,});

  @override
  State<Add_Post> createState() => _Add_PostState();
}

class _Add_PostState extends State<Add_Post> {
  TextEditingController titlecontroller = TextEditingController();

  TextEditingController descriptioncontroller = TextEditingController();

  final ImagePicker picker = ImagePicker();
  late Size size;
  File imageFile = File('');


  void initState(){
    if(widget.title != '' && widget.description != ''){
      titlecontroller.text = widget.title;
      descriptioncontroller.text = widget.description;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.type} Post'),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: TextField(
              controller: titlecontroller,
              decoration: InputDecoration(
                labelText: 'title',
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(width: 2, color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(width: 2, color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: TextField(
              controller: descriptioncontroller,
              decoration: InputDecoration(
                labelText: 'description',
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(width: 2, color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(width: 2, color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              minLines: 4,
              maxLines: 6,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          TextButton.icon(
            onPressed: () async {
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                imageFile = File(image.path);
              }
              setState(() {});
            },
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Add Picture'),
          ),
          selectedImage(),
          const Spacer(),
          GestureDetector(
            onTap: () {
              if(widget.type == 'Add'){
                addPost();
                Navigator.pop(context);
              }
              else{
                updatePost();
                Timer(Duration(seconds: 4), () {
                  CircularProgressIndicator();
                });

                Navigator.pop(context);
              }
            },
            child: Container(
              width: size.width,
              height: size.height * 0.09,
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  topLeft: Radius.circular(25),
                ),
              ),
              child: Center(
                child: Text(
                  '${widget.type} Post',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void addPost() async {
    String title = titlecontroller.text;
    String description = descriptioncontroller.text;

    if (title.isEmpty || description.isEmpty) {}

    Map<String, dynamic> map = Map();
    map['title'] = title;
    map['description'] = description;
    if (imageFile.path != '') {
      map['file'] = await MultipartFile.fromFile(imageFile.path);
    }

    Dio dio = Dio();
    FormData formData = FormData.fromMap(map);
    dio.post(
      '$kBaseUrl/api/post/create/',
      data: formData,
      options: Options(
        method: 'POST',
        headers: {HttpHeaders.authorizationHeader: widget.token},
        responseType: ResponseType.json,
      ),
    );
  }

  void updatePost() async {
    String title = titlecontroller.text;
    String description = descriptioncontroller.text;

    if (title.isEmpty || description.isEmpty) {}

    Map<String, dynamic> map = Map();
    map['title'] = title;
    map['description'] = description;
    if (imageFile.path != '') {
      map['file'] = await MultipartFile.fromFile(imageFile.path);
    }

    Dio dio = Dio();
    FormData formData = FormData.fromMap(map);
    dio.put(
      '$kBaseUrl/api/post/update/${widget.postid}/',
      data: formData,
      options: Options(
        method: 'UPDATE',
        headers: {HttpHeaders.authorizationHeader: widget.token},
        responseType: ResponseType.json,
      ),
    ).then((Response response){
      print(response.statusCode);
      print(response.data);
    });
  }

  Widget selectedImage() {
    if (imageFile.path != '') {
      return Image.file(
        imageFile,
        height: 250,
      );
    } //
    else {
      return Container();
    }
  }
}
