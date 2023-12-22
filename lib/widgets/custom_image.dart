import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


class chachedNetworkImage extends StatelessWidget {
  final String mediaUrl;
  const chachedNetworkImage({super.key, required this.mediaUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    placeholder: (context, url) => const Padding(
      padding: EdgeInsets.all(20),
      child: CircularProgressIndicator(),
    ),
    errorWidget: (context, url, error) => const Icon(
      Icons.error,
      color: Colors.red,
    ),
  );
  }
}