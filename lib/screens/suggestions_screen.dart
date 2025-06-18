import 'package:flutter/material.dart';
import 'package:myapp/widgets/navigation_drawer.dart';
class SuggestionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suggestions'),
      ),
       drawer: AppNavigationDrawer(currentPage: 'Suggestions'),
      body: Center(
        child: Text('Suggestions Screen'),
      ),
    );
  }
}