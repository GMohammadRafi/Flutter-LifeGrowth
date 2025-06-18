import 'package:flutter/material.dart';
import 'package:myapp/widgets/navigation_drawer.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health'),
      ),
      drawer: AppNavigationDrawer(currentPage: 'Health'),
      body: Center(
        child: Text('Health Screen'),
      ),
    );
  }
}
