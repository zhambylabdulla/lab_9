import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FourthPage extends StatefulWidget {
  const FourthPage({super.key});

  @override
  State<FourthPage> createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  String fullName = '';
  String email = '';
  String phone = '';
  String country = '';
  String story = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName') ?? '';
      email = prefs.getString('email') ?? '';
      phone = prefs.getString('phone') ?? '';
      country = prefs.getString('country') ?? '';
      story = prefs.getString('story') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Column(
            children: [
              ListTile(title: Text('ФИО: $fullName')),
              ListTile(title: Text('Email: $email')),
              ListTile(title: Text('Телефон: $phone')),
              ListTile(title: Text('Страна: $country')),
              ListTile(title: Text('История: $story')),
            ],
          ),
        ),
      ),
    );
  }
}
