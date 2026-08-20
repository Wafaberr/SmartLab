import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:smartlaboratory/core/constants/endpoints.dart';
import 'package:smartlaboratory/features/products/data/models/product_model.dart';

Widget productImage(ProductModel product) {
  final image = product.image;

  if (image == null || image.isEmpty) {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey[300],
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }

  if (image.startsWith('data:')) {
    final commaIndex = image.indexOf(',');
    if (commaIndex > 0) {
      try {
        final bytes = base64Decode(image.substring(commaIndex + 1));
        return Image.memory(
          Uint8List.fromList(bytes),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _imageError(),
        );
      } on FormatException {
        return _imageError();
      }
    }
    return _imageError();
  }

  final imageUrl = image.startsWith('http')
      ? image
      : '${Endpoints.baseUrl}${image.startsWith('/') ? image.substring(1) : image}';

  return Image.network(
    imageUrl,
    width: 50,
    height: 50,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return _imageError();
    },
  );
}

Widget _imageError() {
  return Container(
    width: 50,
    height: 50,
    color: Colors.grey[300],
    child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
  );
}
