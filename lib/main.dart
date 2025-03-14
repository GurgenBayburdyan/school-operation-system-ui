import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:school_operation_system_ui/create_class_screen.dart';
import 'package:school_operation_system_ui/create_school_screen.dart';
import 'package:school_operation_system_ui/create_pupil_screen.dart';
import 'package:http/http.dart' as http;
import 'create_staff_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;

  final pages = [
    const AddPupil(),
    const AddStaff(),
    const AddSchool(),
    const AddClass()
  ];

  String appBarTitle = '';
  Color appBarColor = Colors.green[700]!;

  @override
  Widget build(BuildContext context) {

    if (index == 0) {
      appBarTitle = 'Pupils Management';
      appBarColor = Colors.green[700]!;
    } else if (index == 1) {
      appBarTitle = 'Staff Management';
      appBarColor = Colors.blue[900]!;
    } else if (index == 2) {
      appBarTitle = 'School Management';
      appBarColor = Colors.orange[900]!;
    } else if (index == 3) {
      appBarTitle = 'Class Management';
      appBarColor = Colors.brown[700]!;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(appBarTitle),

      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text(
                'Pupils',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                setState(() {
                  index = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(
                'Staff',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                setState(() {
                  index = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(
                'Schools',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                setState(() {
                  index = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(
                'Classes',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                setState(() {
                  index = 3;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: pages[index],
    );
  }
}
