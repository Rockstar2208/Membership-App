import 'package:flutter/material.dart';
import '../models/feature.dart';

class FeatureScreen extends StatelessWidget{
  final Feature feature;
   const FeatureScreen({super.key, required this.feature});

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(feature.name)
      ),
      body: Center(
        child: Text('${feature.name} is coming soon')
      ),
    );
  }
}