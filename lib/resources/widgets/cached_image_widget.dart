import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImageWidget extends StatelessWidget {
  const CachedImageWidget({
    Key? key,
    this.image,
    this.height = 70,
    this.width = 70,
    this.placeholder = const Center(
      child: CircularProgressIndicator(
          strokeWidth: 2,
          backgroundColor: Colors.black12,
          color: Colors.black54),
    ),
    this.fit = BoxFit.contain,
  }) : super(key: key);

  final String? image;
  final double height;
  final double width;
  final Widget placeholder;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        imageUrl: image!,
        placeholder: (context, url) => placeholder,
        errorWidget: (context, url, error) => Icon(Icons.error),
        height: height,
        width: width,
        alignment: Alignment.center,
        fit: fit,
      );
}
