import 'package:flutter/material.dart';
import 'package:myapp/widgets/navigation_drawer.dart';


class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: AppNavigationDrawer(currentPage: 'Dashboard'),
 body: Center(
        child: Text('Dashboard Screen'),
      )
    );
  }
}