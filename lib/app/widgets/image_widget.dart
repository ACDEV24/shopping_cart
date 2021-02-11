import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {

  final String picture;
  final double size;
  final FilterQuality filterQuality;
  const ImageWidget(this.picture, [this.size = 40.0, this.filterQuality = FilterQuality.low]);

  @override
  ClipRRect build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(100.0),
    child: CachedNetworkImage(
      imageUrl: picture,
      placeholder: (context, url) => Image(
        image: AssetImage('assets/loading.gif'), 
        height: size,
        width: size,
        fit: BoxFit.cover
      ),
      errorWidget: (_, __, ___) => Icon(Icons.error),
      height: size,
      width: size,
      fit: BoxFit.cover,
      filterQuality: filterQuality
    ),
  );
}