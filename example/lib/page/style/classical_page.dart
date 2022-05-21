import 'package:flutter/material.dart';

class ClassicalPage extends StatefulWidget {
  const ClassicalPage({Key? key}) : super(key: key);

  @override
  State<ClassicalPage> createState() => _ClassicalPageState();
}

class _ClassicalPageState extends State<ClassicalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classical'),
      ),
    );
  }
}
