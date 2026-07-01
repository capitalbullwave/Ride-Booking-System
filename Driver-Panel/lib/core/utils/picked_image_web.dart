import 'package:flutter/material.dart';

Widget pickedImage(String path, {BoxFit fit = BoxFit.cover}) {
  return Image.network(path, fit: fit);
}
