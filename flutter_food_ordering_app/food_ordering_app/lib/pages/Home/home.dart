import 'package:flutter/material.dart';
import 'package:food_ordering_app/models/NguoiDung.dart';

class HomePage extends StatelessWidget {
  final NguoiDung user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text(
          "Chào mừng ${user.hoTen} đến với HomePage!",
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
