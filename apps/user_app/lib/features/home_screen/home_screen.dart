import 'package:flutter/material.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Home Screen', style: AppTextStyles().fontBlack20Bold),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.search, color: Colors.black),
          ),
        ],
      ),
      body: Center(child: Text("Home Screen"))
    );
  }
}

