import 'package:easy_refresh/easy_refresh.dart';
import 'package:easy_refresh_bow/easy_refresh_bow.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Bow',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _count = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bow'),
      ),
      body: EasyRefresh(
        header: const BowHeader(),
        footer: const BowFooter(),
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;
          setState(() {
            _count = 10;
          });
        },
        onLoad: () async {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;
          setState(() {
            _count += 5;
          });
        },
        child: ListView.builder(
          itemCount: _count,
          itemBuilder: (context, index) {
            return Card(
              child: Container(
                alignment: Alignment.center,
                height: 80,
                child: Text('${index + 1}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
