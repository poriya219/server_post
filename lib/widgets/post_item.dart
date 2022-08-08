import 'package:flutter/material.dart';
import 'package:server_post/models/post.dart';

import '../const.dart';

class Post_Item extends StatelessWidget {
  Post post;
  final VoidCallback onDeletePressed;
  final VoidCallback onUpdatePressed;

  Post_Item(
      {required this.post,
      required this.onDeletePressed,
      required this.onUpdatePressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onUpdatePressed,
        leading: FadeInImage(
          placeholder: const AssetImage('assets/images/default.png'),
          image: showImage(post.imageurl),
        ),
        title: Text(post.text),
        subtitle: Text(post.description),
        trailing: IconButton(onPressed: onDeletePressed, icon: const Icon(Icons.delete_forever)),
      ),
    );
  }

  ImageProvider showImage(String image) {
    if (image.isNotEmpty) {
      return NetworkImage('$kBaseUrl/media/$image');
    } //
    else {
      return const AssetImage(
        'assets/images/default.png',
      );
    }
  }

}
