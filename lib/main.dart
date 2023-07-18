import 'package:flutter/material.dart';
import 'package:form_application/widget/grocery_list.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget{
  MyApp ({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Flutter Groceries',
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromARGB(255, 147, 229, 250),
          brightness: Brightness.dark,
          surface: Color.fromARGB(255, 42, 51, 59),
        ),
        scaffoldBackgroundColor: Color.fromARGB(255, 50, 58, 60)
      ),
      home: GroceryList(),
    );
  }
}
