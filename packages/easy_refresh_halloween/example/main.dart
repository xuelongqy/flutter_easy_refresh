import 'package:easy_refresh_halloween/easy_refresh_halloween.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Halloween',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _count = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halloween'),
      ),
      body: EasyRefresh(
        header: const HalloweenHeader(),
        footer: const HalloweenFooter(),
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 4));
          if (!mounted) {
            return;
          }
          setState(() {
            _count = 10;
          });
        },
        onLoad: () async {
          await Future.delayed(const Duration(seconds: 4));
          if (!mounted) {
            return;
          }
          setState(() {
            _count += 5;
          });
        },
        child: ListView.builder(
          itemBuilder: (context, index) {
            return Card(
              child: Container(
                alignment: Alignment.center,
                height: 80,
                child: Text('${index + 1}'),
              ),
            );
          },
          itemCount: _count,
        ),
      ),
    );
  }
}
