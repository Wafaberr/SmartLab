import 'package:flutter/material.dart';
import 'package:smartlaboratory/features/products/data/models/product_model.dart';

Widget productImage(ProductModel product) {
  final image = product.image;

  if (image == null ||
      image.isEmpty ||
      !image.startsWith('http')) {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey[300],
      child: const Icon(
        Icons.image_outlined,
        color: Colors.grey,
      ),
    );
  }

  return Image.network(
    image,
    width: 50,
    height: 50,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        width: 50,
        height: 50,
        color: Colors.grey[300],
        child: const Icon(
          Icons.broken_image_outlined,
          color: Colors.grey,
        ),
      );
    },
  );
}