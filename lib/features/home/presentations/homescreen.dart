import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiss/features/riders/providers/riders_providers.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(context.read<RidersProvider>().loadRiders);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: SafeArea(child: Column(children: [])),
    );
  }
}
