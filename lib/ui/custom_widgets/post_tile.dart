import 'package:flutter/material.dart';
import 'package:fluttershare/ui/custom_widgets/custom_image.dart';
import 'package:fluttershare/ui/screens/posts_screen.dart';

class PostTile extends StatelessWidget {
  final PostsScreen post;
  PostTile({this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('full screen'),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
