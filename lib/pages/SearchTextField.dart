import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Search'),
      ),
    );
  }
}
